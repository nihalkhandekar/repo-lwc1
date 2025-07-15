export function loadScript(scriptUrl) {
    return new Promise((resolve, reject) => {
        if (document.querySelector(`script[src="${scriptUrl}"]`)) {
            resolve(); // Script already loaded
            return;
        }
        const script = document.createElement('script');
        script.src = scriptUrl;
        script.onload = resolve;
        script.onerror = reject;
        document.head.appendChild(script);
    });
}