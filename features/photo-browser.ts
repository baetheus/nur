// Run: deno run --allow-net --allow-read --allow-write main.ts
// Env: MEDIA_ROOT (default ./media), HOST (default 127.0.0.1), PORT (default 8000)
import { serveFile } from "jsr:@std/http@1/file-server";
import { join } from "jsr:@std/path@1";

const ROOT = Deno.env.get("MEDIA_ROOT") ?? "./media";
const HOST = Deno.env.get("HOST") ?? "127.0.0.1";
const PORT = Number(Deno.env.get("PORT") ?? 8000);
const TMP = join(ROOT, ".tmp");
const IMG = /\.(jpe?g|png|gif|webp|avif|heic)$/i;
const VID = /\.(mp4|mov|m4v|webm|mkv|avi)$/i;

await Deno.mkdir(TMP, { recursive: true });

const esc = (s: string) =>
  s.replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`);
const pad = (n: number) => String(n).padStart(2, "0");

// Minimal JPEG EXIF reader -> "YYYY/MM/DD" or null
function exifDate(b: Uint8Array): string | null {
  try {
    const dv = new DataView(b.buffer, b.byteOffset, b.byteLength);
    if (b.length < 4 || dv.getUint16(0) !== 0xffd8) return null;
    let p = 2;
    while (p + 4 < b.length) {
      if (b[p] !== 0xff) return null;
      const marker = b[p + 1], len = dv.getUint16(p + 2);
      if (marker === 0xda) return null;
      if (
        marker === 0xe1 &&
        String.fromCharCode(...b.subarray(p + 4, p + 8)) === "Exif"
      ) {
        const t = p + 10;
        const le = dv.getUint16(t) === 0x4949;
        const u16 = (o: number) => dv.getUint16(t + o, le);
        const u32 = (o: number) => dv.getUint32(t + o, le);
        const find = (ifd: number, tag: number): number | null => {
          const n = u16(ifd);
          for (let i = 0; i < n; i++) {
            const e = ifd + 2 + i * 12;
            if (u16(e) === tag) return u32(e + 8);
          }
          return null;
        };
        const read = (o: number | null) =>
          o !== null && t + o + 19 <= b.length
            ? new TextDecoder().decode(b.subarray(t + o, t + o + 19))
            : null;
        const ifd0 = u32(4);
        const sub = find(ifd0, 0x8769);
        const s = (sub !== null ? read(find(sub, 0x9003)) : null) ??
          read(find(ifd0, 0x0132));
        const m = s?.match(/^(\d{4}):(\d{2}):(\d{2})/);
        return m && m[1] !== "0000" ? `${m[1]}/${m[2]}/${m[3]}` : null;
      }
      p += 2 + len;
    }
  } catch { /* ignore */ }
  return null;
}

async function exists(p: string) {
  try {
    await Deno.stat(p);
    return true;
  } catch {
    return false;
  }
}

async function upload(req: Request): Promise<Response> {
  if (!req.body) return new Response("no body", { status: 400 });
  let name = decodeURIComponent(req.headers.get("x-name") ?? "upload");
  name = name.split(/[\\/]/).pop()!.replace(/[^\w.\- ()]/g, "_").replace(/^\.+/, "_");
  if (!IMG.test(name) && !VID.test(name)) {
    return new Response("unsupported type", { status: 415 });
  }
  const tmp = join(TMP, crypto.randomUUID());
  const f = await Deno.open(tmp, { write: true, create: true });
  await req.body.pipeTo(f.writable);

  let date: string | null = null;
  if (/\.jpe?g$/i.test(name)) {
    const r = await Deno.open(tmp);
    const buf = new Uint8Array(262144);
    const n = (await r.read(buf)) ?? 0;
    r.close();
    date = exifDate(buf.subarray(0, n));
  }
  if (!date) {
    const ms = Number(req.headers.get("x-mtime"));
    const d = ms > 0 ? new Date(ms) : new Date();
    date = `${d.getFullYear()}/${pad(d.getMonth() + 1)}/${pad(d.getDate())}`;
  }

  const dir = join(ROOT, date);
  await Deno.mkdir(dir, { recursive: true });
  const dot = name.lastIndexOf(".");
  const base = name.slice(0, dot), ext = name.slice(dot);
  let final = name;
  for (let i = 1; await exists(join(dir, final)); i++) final = `${base}-${i}${ext}`;
  await Deno.rename(tmp, join(dir, final));
  return new Response(`${date}/${final}`);
}

async function subdirs(p: string, re: RegExp) {
  const out: string[] = [];
  for await (const e of Deno.readDir(p)) if (e.isDirectory && re.test(e.name)) out.push(e.name);
  return out.sort().reverse(); // newest first
}

const page = (title: string, body: string) =>
  new Response(
    `<!doctype html><meta charset=utf-8><meta name=viewport content="width=device-width,initial-scale=1">
<title>${esc(title)}</title>
<style>
body{font:16px system-ui;margin:1rem;max-width:1200px;margin-inline:auto;color:#222;background:#fff}
@media(prefers-color-scheme:dark){body{color:#ddd;background:#111}a{color:#8ab4f8}}
nav{margin-bottom:1rem}
ul.l{list-style:none;padding:0;display:flex;flex-wrap:wrap;gap:.5rem}
ul.l a{display:block;padding:.5rem 1rem;border:1px solid #8886;border-radius:6px;text-decoration:none}
.g{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:6px}
.g img,.g video{width:100%;height:220px;object-fit:cover;background:#8883;display:block}
#st{margin-left:.5rem}
</style>
${body}`,
    { headers: { "content-type": "text/html; charset=utf-8" } },
  );

const uploadForm = `<p><input type=file id=f multiple accept="image/*,video/*">
<button onclick="up()">Upload</button><span id=st></span></p>
<script>
async function up(){
  const fs=[...document.getElementById('f').files],st=document.getElementById('st');
  let i=0;
  for(const f of fs){
    st.textContent='Uploading '+(++i)+'/'+fs.length+'…';
    const r=await fetch('/upload',{method:'POST',headers:{'x-name':encodeURIComponent(f.name),'x-mtime':String(f.lastModified)},body:f});
    if(!r.ok){st.textContent='Failed: '+f.name+' ('+await r.text()+')';return;}
  }
  location.reload();
}
</script>`;

async function browse(path: string): Promise<Response> {
  const parts = path.split("/").filter(Boolean);
  const dir = join(ROOT, ...parts);
  if (!(await exists(dir))) return new Response("not found", { status: 404 });
  const crumbs = ["<a href='/'>Home</a>"];
  parts.forEach((_, i) => {
    const href = "/" + parts.slice(0, i + 1).join("/");
    crumbs.push(`<a href="${href}">${parts[i]}</a>`);
  });
  const nav = `<nav>${crumbs.join(" / ")}</nav>`;

  if (parts.length < 3) {
    const re = parts.length === 0 ? /^\d{4}$/ : /^\d{2}$/;
    const items = (await subdirs(dir, re))
      .map((n) => `<li><a href="/${[...parts, n].join("/")}">${n}</a></li>`)
      .join("");
    return page("Photos", nav + (parts.length === 0 ? uploadForm : "") + `<ul class=l>${items}</ul>`);
  }

  const files: string[] = [];
  for await (const e of Deno.readDir(dir)) {
    if (e.isFile && (IMG.test(e.name) || VID.test(e.name))) files.push(e.name);
  }
  files.sort();
  const items = files.map((n) => {
    const u = `/m/${parts.join("/")}/${encodeURIComponent(n)}`;
    return VID.test(n)
      ? `<video src="${u}" controls preload=metadata></video>`
      : `<a href="${u}"><img src="${u}" loading=lazy alt="${esc(n)}"></a>`;
  }).join("");
  return page(parts.join("-"), nav + `<div class=g>${items}</div>`);
}

Deno.serve({ hostname: HOST, port: PORT }, async (req) => {
  const url = new URL(req.url);
  const path = decodeURIComponent(url.pathname);
  try {
    if (req.method === "POST" && path === "/upload") return await upload(req);
    if (req.method !== "GET" && req.method !== "HEAD") {
      return new Response("method not allowed", { status: 405 });
    }
    if (path.startsWith("/m/")) {
      const rel = path.slice(3);
      if (!/^\d{4}\/\d{2}\/\d{2}\/[^/\\]+$/.test(rel) || rel.includes("..")) {
        return new Response("bad path", { status: 400 });
      }
      return await serveFile(req, join(ROOT, rel)); // handles Range
    }
    if (/^\/(\d{4}(\/\d{2}(\/\d{2})?)?)?\/?$/.test(path)) return await browse(path);
    return new Response("not found", { status: 404 });
  } catch (e) {
    console.error(e);
    return new Response("error", { status: 500 });
  }
});
