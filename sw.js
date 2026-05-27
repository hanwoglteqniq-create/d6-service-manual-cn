// Service Worker - 离线缓存策略
const CACHE_NAME = 'd6-manual-v1';
const CACHE_URLS = self.location.pathname.replace(/sw\.js$/, '');

// 安装时预缓存关键资源
self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            return cache.addAll([
                './',
                './index.html',
                './manual/mobile.css',
                './manual/menu_data.json',
                './manual/welcome.html',
                './manual/common_e2/css/manual.css',
                './manifest.json',
                './icon-192.png',
                './icon-512.png'
            ]);
        }).then(() => self.skipWaiting())
    );
});

// 激活时清理旧缓存
self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then((keys) => {
            return Promise.all(
                keys.filter((key) => key !== CACHE_NAME)
                    .map((key) => caches.delete(key))
            );
        }).then(() => self.clients.claim())
    );
});

// 请求策略：缓存优先，网络回退
self.addEventListener('fetch', (event) => {
    // 只处理同源请求
    if (!event.request.url.startsWith(self.location.origin)) return;

    event.respondWith(
        caches.match(event.request).then((cached) => {
            if (cached) return cached;

            return fetch(event.request).then((response) => {
                // 成功获取后缓存
                if (response.ok) {
                    const clone = response.clone();
                    caches.open(CACHE_NAME).then((cache) => {
                        cache.put(event.request, clone);
                    });
                }
                return response;
            }).catch(() => {
                // 离线回退
                if (event.request.destination === 'document') {
                    return caches.match('./index.html');
                }
            });
        })
    );
});
