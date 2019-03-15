const fsStore = require('cache-manager-fs');
const requestPlus = require('request-plus');
const cacheManager = require('cache-manager');
const delay = 5000;
const cacheReady = new Promise(
    function (resolve) {
        const cache = cacheManager.caching({
            store: fsStore,
            options: {
                ttl: 6 * 60 * 60 /* seconds */,
                maxsize: 100e6 /* max size in bytes on disk */,
                fillcallback: () => resolve(cache),
            },
        });
    }
).then(cache => requestPlus({cache: {cache}}));

function pause(result) {
    return new Promise(function (resolve) {
        setTimeout(() => resolve(result), delay);
    });
}

module.exports = function (...args) {
    return cacheReady.then(pause)
        .then(rp => rp(...args));
};
