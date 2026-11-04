/* Guarda la app en el teléfono para que abra aun sin internet. Sube VERSION al publicar cambios. */
const VERSION='gastos-v9';
const SHELL=['./','index.html','config.js','manifest.webmanifest','vendor/supabase.js','icons/icon-180.png','icons/icon-192.png','icons/icon-512.png'];
self.addEventListener('install',e=>{e.waitUntil(caches.open(VERSION).then(c=>c.addAll(SHELL)).then(()=>self.skipWaiting()))});
self.addEventListener('activate',e=>{e.waitUntil(caches.keys().then(ks=>Promise.all(ks.filter(k=>k!==VERSION).map(k=>caches.delete(k)))).then(()=>self.clients.claim()))});
self.addEventListener('fetch',e=>{
  const req=e.request, url=new URL(req.url);
  if(req.method!=='GET'||url.origin!==location.origin) return;
  const fresh=req.mode==='navigate'||/\/(index\.html|config\.js)?$/.test(url.pathname)||url.pathname.endsWith('config.js');
  if(fresh){ e.respondWith(fetch(req).then(r=>{const c=r.clone();caches.open(VERSION).then(x=>x.put(req,c));return r}).catch(()=>caches.match(req).then(r=>r||caches.match('index.html')))); return }
  e.respondWith(caches.match(req).then(r=>r||fetch(req).then(n=>{const c=n.clone();caches.open(VERSION).then(x=>x.put(req,c));return n})));
});
