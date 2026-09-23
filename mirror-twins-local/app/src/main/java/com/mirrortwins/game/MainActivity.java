package com.mirrortwins.game;

import android.app.Activity;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.webkit.JavascriptInterface;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONObject;

public class MainActivity extends Activity {
    private static final String ONLINE_HOST = "mt.grafixers.co.uk";
    private static final String STORAGE_PREFS = "mirror_twins_updater";
    private static final String STORAGE_KEY = "web_storage_json";

    private WebView webView;
    private UpdateManager updateManager;
    private boolean returningToLocal = false;
    private boolean autoCheckStarted = false;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        try {
            Window window = getWindow();
            window.setStatusBarColor(Color.rgb(8, 16, 36));
            window.setNavigationBarColor(Color.rgb(8, 16, 36));
            window.getDecorView().setSystemUiVisibility(
                    View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);

            webView = new WebView(this);
            webView.setBackgroundColor(Color.rgb(8, 16, 36));
            setContentView(webView);

            WebSettings settings = webView.getSettings();
            settings.setJavaScriptEnabled(true);
            settings.setDomStorageEnabled(true);
            settings.setDatabaseEnabled(true);
            settings.setAllowFileAccess(true);
            settings.setAllowContentAccess(true);
            settings.setAllowFileAccessFromFileURLs(false);
            settings.setAllowUniversalAccessFromFileURLs(false);
            settings.setMediaPlaybackRequiresUserGesture(false);
            settings.setBuiltInZoomControls(false);
            settings.setDisplayZoomControls(false);
            settings.setSupportZoom(false);

            updateManager = new UpdateManager(this, () -> loadGame(false));
            webView.addJavascriptInterface(new NativeUpdateBridge(), "NativeUpdater");

            webView.setWebViewClient(new WebViewClient() {
                @Override
                public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
                    super.onReceivedError(view, request, error);
                    if (request == null || !request.isForMainFrame()) return;

                    Uri url = request.getUrl();
                    if (url == null) return;

                    if (ONLINE_HOST.equalsIgnoreCase(url.getHost()) && !returningToLocal) {
                        returningToLocal = true;
                        loadGame(true);
                        return;
                    }

                    String raw = url.toString();
                    if (raw.contains("/game-current/")) {
                        boolean restored = updateManager.rollbackGame();
                        Toast.makeText(MainActivity.this,
                                restored
                                        ? "Downloaded game failed to open. Previous version restored."
                                        : "Downloaded game failed to open. Using bundled version.",
                                Toast.LENGTH_LONG).show();
                        loadGame(false);
                    }
                }

                @Override
                public void onPageFinished(WebView view, String url) {
                    super.onPageFinished(view, url);
                    if (isLocalGameUrl(url)) {
                        returningToLocal = false;
                        restoreMissingLocalStorage(view);
                        installStorageBackupHook(view);
                    }
                }
            });

            webView.setWebChromeClient(new WebChromeClient());
            loadGame(false);

            if (!autoCheckStarted) {
                autoCheckStarted = true;
                webView.postDelayed(() -> {
                    if (updateManager != null) updateManager.checkForUpdates(false);
                }, 1800);
            }
        } catch (Throwable t) {
            showStartupError(t);
        }
    }

    private void loadGame(boolean onlineUnavailable) {
        if (webView == null || updateManager == null) return;
        String url = updateManager.getGameEntryUrl();
        if (onlineUnavailable) {
            url = appendQuery(url, "online=unavailable");
        }
        webView.loadUrl(url);
    }

    private String appendQuery(String url, String query) {
        return url + (url.contains("?") ? "&" : "?") + query;
    }

    private boolean isLocalGameUrl(String url) {
        if (url == null) return false;
        return url.startsWith("file:///android_asset/www/") ||
                url.contains("/files/game-current/");
    }

    private void restoreMissingLocalStorage(WebView view) {
        String backup = getSharedPreferences(STORAGE_PREFS, MODE_PRIVATE)
                .getString(STORAGE_KEY, "");
        if (backup == null || backup.trim().isEmpty()) return;

        String quoted = JSONObject.quote(backup);
        String script =
                "(function(){try{" +
                "var d=JSON.parse(" + quoted + ");" +
                "var changed=false;" +
                "Object.keys(d).forEach(function(k){" +
                "if(localStorage.getItem(k)===null){localStorage.setItem(k,String(d[k]));changed=true;}" +
                "});" +
                "if(changed&&!sessionStorage.getItem('__mt_restored')){" +
                "sessionStorage.setItem('__mt_restored','1');location.reload();" +
                "}" +
                "}catch(e){}})();";
        view.evaluateJavascript(script, null);
    }

    private void installStorageBackupHook(WebView view) {
        String script =
                "(function(){" +
                "if(window.__mtNativeBackupInstalled)return;" +
                "window.__mtNativeBackupInstalled=true;" +
                "function snap(){try{" +
                "var o={};for(var i=0;i<localStorage.length;i++){" +
                "var k=localStorage.key(i);o[k]=localStorage.getItem(k);" +
                "}if(window.NativeUpdater)NativeUpdater.backupStorage(JSON.stringify(o));" +
                "}catch(e){}}" +
                "snap();window.__mtNativeBackupTimer=setInterval(snap,3000);" +
                "document.addEventListener('visibilitychange',function(){if(document.hidden)snap();});" +
                "})();";
        view.evaluateJavascript(script, null);
    }

    private void backupStorageNow() {
        if (webView == null) return;
        webView.evaluateJavascript(
                "(function(){try{var o={};for(var i=0;i<localStorage.length;i++){" +
                "var k=localStorage.key(i);o[k]=localStorage.getItem(k);}return JSON.stringify(o);" +
                "}catch(e){return '{}';}})();",
                value -> {
                    try {
                        if (value == null || "null".equals(value)) return;
                        String decoded = new org.json.JSONTokener(value).nextValue().toString();
                        saveStorageBackup(decoded);
                    } catch (Exception ignored) {
                    }
                });
    }

    private void saveStorageBackup(String json) {
        if (json == null || json.length() > 1024 * 1024) return;
        getSharedPreferences(STORAGE_PREFS, MODE_PRIVATE)
                .edit()
                .putString(STORAGE_KEY, json)
                .apply();
    }

    private class NativeUpdateBridge {
        @JavascriptInterface
        public void checkForUpdates() {
            runOnUiThread(() -> {
                if (updateManager != null) updateManager.checkForUpdates(true);
            });
        }

        @JavascriptInterface
        public String getAppVersion() {
            return updateManager == null ? "Unknown" :
                    updateManager.getAppVersionName();
        }

        @JavascriptInterface
        public String getGameVersion() {
            return updateManager == null ? "Bundled" :
                    updateManager.getGameVersionName();
        }

        @JavascriptInterface
        public void backupStorage(String json) {
            saveStorageBackup(json);
        }
    }

    private void showStartupError(Throwable t) {
        TextView error = new TextView(this);
        error.setTextColor(Color.WHITE);
        error.setBackgroundColor(Color.rgb(8, 16, 36));
        error.setPadding(40, 60, 40, 40);
        error.setTextSize(16f);
        error.setText("Mirror Twins could not open.\n\n" +
                t.getClass().getSimpleName() + ": " + String.valueOf(t.getMessage()) +
                "\n\nThe bundled game remains available without internet.");
        setContentView(error);
    }

    @Override
    protected void onPause() {
        backupStorageNow();
        if (webView != null) webView.onPause();
        super.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (webView != null) webView.onResume();
        if (updateManager != null) updateManager.resumePendingInstallIfAllowed();
    }

    @Override
    public void onBackPressed() {
        if (webView != null && webView.canGoBack()) {
            webView.goBack();
        } else {
            super.onBackPressed();
        }
    }
}
