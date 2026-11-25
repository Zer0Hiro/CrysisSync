// Cloudflare Worker: relays Linear webhooks (issue created, status changed, comment added) to a Discord channel.
// Secrets (set by tools/discord/setup.sh): LINEAR_WEBHOOK_SECRET = signing secret of the Linear webhook,
// DISCORD_WEBHOOK_URL = webhook of the #linear channel.
const MAX_AGE_MS = 60_000; // reject replays of old deliveries
const enc = new TextEncoder();

async function validSignature(secret, body, signature) {
  if (!secret || !signature) return false;
  const key = await crypto.subtle.importKey("raw", enc.encode(secret), { name: "HMAC", hash: "SHA-256" }, false, ["sign"]);
  const mac = new Uint8Array(await crypto.subtle.sign("HMAC", key, enc.encode(body)));
  const expected = enc.encode([...mac].map((b) => b.toString(16).padStart(2, "0")).join(""));
  const given = enc.encode(signature);
  return expected.byteLength === given.byteLength && crypto.subtle.timingSafeEqual(expected, given);
}

const color = (hex) => (hex ? parseInt(hex.replace("#", ""), 16) : 0x5e6ad2);

// Returns a Discord embed for the events we care about, or null to ignore the event.
function toEmbed(p) {
  const d = p.data ?? {};
  const who = p.actor?.name ?? "Someone";

  if (p.type === "Issue") {
    let what;
    if (p.action === "create") what = "created this issue";
    else if (p.action === "update" && p.updatedFrom && "stateId" in p.updatedFrom) what = `moved it to **${d.state?.name ?? "?"}**`;
    else return null;
    const fields = [
      { name: "Status", value: d.state?.name ?? "-", inline: true },
      { name: "Assignee", value: d.assignee?.name ?? "Unassigned", inline: true },
    ];
    if (d.labels?.length) fields.push({ name: "Labels", value: d.labels.map((l) => l.name).join(", "), inline: true });
    return {
      title: `${d.identifier} ${d.title}`.slice(0, 256),
      url: p.url,
      description: `${who} ${what}`,
      color: color(d.state?.color),
      fields,
      timestamp: d.updatedAt,
    };
  }

  if (p.type === "Comment" && p.action === "create") {
    const issue = d.issue ?? {};
    return {
      title: `Comment on ${issue.identifier ?? ""} ${issue.title ?? ""}`.trim().slice(0, 256),
      url: p.url,
      description: `**${who}:** ${d.body ?? ""}`.slice(0, 4000),
      color: color(),
      timestamp: d.createdAt,
    };
  }

  return null;
}

export default {
  async fetch(request, env) {
    if (request.method !== "POST") return new Response("Method not allowed", { status: 405 });

    const body = await request.text();
    if (!(await validSignature(env.LINEAR_WEBHOOK_SECRET, body, request.headers.get("linear-signature")))) {
      return new Response("Invalid signature", { status: 401 });
    }
    let payload;
    try {
      payload = JSON.parse(body);
    } catch {
      return new Response("Bad JSON", { status: 400 });
    }
    if (!(Math.abs(Date.now() - payload.webhookTimestamp) <= MAX_AGE_MS)) {
      return new Response("Stale webhook", { status: 401 });
    }

    const embed = toEmbed(payload);
    if (!embed) return new Response("Ignored");

    const res = await fetch(env.DISCORD_WEBHOOK_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      // allowed_mentions: a comment containing @everyone must not ping the server
      body: JSON.stringify({ username: "Linear", embeds: [embed], allowed_mentions: { parse: [] } }),
    });
    return res.ok ? new Response("OK") : new Response(`Discord returned ${res.status}`, { status: 502 });
  },
};
