package com.mirrortwins.game;

import android.Manifest;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.content.Intent;
import android.provider.Settings;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.webkit.JavascriptInterface;
import android.webkit.PermissionRequest;
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
    private static final int AUDIO_PERMISSION_REQUEST = 4201;

    private WebView webView;
    private UpdateManager updateManager;
    private boolean returningToLocal = false;
    private boolean autoCheckStarted = false;
    private PermissionRequest pendingAudioPermissionRequest;

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

            webView.setWebChromeClient(new WebChromeClient() {
                @Override
                public void onPermissionRequest(PermissionRequest request) {
                    runOnUiThread(() -> handleWebPermissionRequest(request));
                }

                @Override
                public void onPermissionRequestCanceled(PermissionRequest request) {
                    if (pendingAudioPermissionRequest == request) {
                        pendingAudioPermissionRequest = null;
                    }
                }
            });

            loadGame(false);

            if (!autoCheckStarted) {
                autoCheckStarted = true;
                webView.postDelayed(() -> {
                    if (updateManager != null) updateManager.checkForUpdates(false);
                }, 1200);
            }
        } catch (Throwable t) {
            showStartupError(t);
        }
    }

    private void handleWebPermissionRequest(PermissionRequest request) {
        if (request == null) return;
        Uri origin = request.getOrigin();
        boolean trusted = origin != null &&
                "https".equalsIgnoreCase(origin.getScheme()) &&
                ONLINE_HOST.equalsIgnoreCase(origin.getHost());
        boolean wantsAudio = false;
        for (String resource : request.getResources()) {
            if (PermissionRequest.RESOURCE_AUDIO_CAPTURE.equals(resource)) {
                wantsAudio = true;
                break;
            }
        }

        if (!trusted || !wantsAudio) {
            request.deny();
            return;
        }

        if (checkSelfPermission(Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED) {
            request.grant(new String[]{PermissionRequest.RESOURCE_AUDIO_CAPTURE});
            return;
        }

        pendingAudioPermissionRequest = request;
        requestPermissions(new String[]{Manifest.permission.RECORD_AUDIO}, AUDIO_PERMISSION_REQUEST);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode != AUDIO_PERMISSION_REQUEST) return;

        boolean granted = grantResults.length > 0 &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED;

        PermissionRequest request = pendingAudioPermissionRequest;
        pendingAudioPermissionRequest = null;
        if (request != null) {
            if (granted) {
                request.grant(new String[]{PermissionRequest.RESOURCE_AUDIO_CAPTURE});
            } else {
                request.deny();
            }
        }

        dispatchMicPermission(granted);

        if (!granted) {
            Toast.makeText(this,
                    "Microphone stays off. Tap the mic icon to try again.",
                    Toast.LENGTH_LONG).show();
        }
    }

    private void dispatchMicPermission(boolean granted) {
        if (webView == null) return;
        String js = "window.dispatchEvent(new CustomEvent('mirrorTwinsMicPermission',{detail:{granted:" +
                (granted ? "true" : "false") + "}}));";
        webView.evaluateJavascript(js, null);
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
        public String getUpdateStatus() {
            return updateManager == null
                    ? "{\"checked\":false,\"available\":false}"
                    : updateManager.getUpdateStatusJson();
        }

        @JavascriptInterface
        public boolean hasMicrophonePermission() {
            return checkSelfPermission(Manifest.permission.RECORD_AUDIO) ==
                    PackageManager.PERMISSION_GRANTED;
        }

        @JavascriptInterface
        public void requestMicrophonePermission() {
            runOnUiThread(() -> {
                if (checkSelfPermission(Manifest.permission.RECORD_AUDIO) ==
                        PackageManager.PERMISSION_GRANTED) {
                    dispatchMicPermission(true);
                    return;
                }
                requestPermissions(
                        new String[]{Manifest.permission.RECORD_AUDIO},
                        AUDIO_PERMISSION_REQUEST
                );
            });
        }

        @JavascriptInterface
        public void openMicrophoneSettings() {
            runOnUiThread(() -> {
                try {
                    Intent intent = new Intent(
                            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                            Uri.parse("package:" + getPackageName())
                    );
                    startActivity(intent);
                } catch (Exception e) {
                    Toast.makeText(MainActivity.this,
                            "Open Android Settings → Apps → Mirror Twins → Permissions → Microphone.",
                            Toast.LENGTH_LONG).show();
                }
            });
        }

        @JavascriptInterface
        public void backupStorage(String json) {
            saveStorageBackup(json);
        }
    }

    private void dispatchAppLifecycleEvent(String eventName) {
        if (webView == null) return;
        String safe = eventName == null ? "" : eventName.replace("'", "");
        webView.evaluateJavascript(
                "window.dispatchEvent(new Event('" + safe + "'));",
                null
        );
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
        // Release WebRTC microphone BEFORE pausing the WebView. External apps/calls always win.
        dispatchAppLifecycleEvent("mirrorTwinsAppPaused");
        if (webView != null) webView.onPause();
        super.onPause();
    }

    @Override
    protected void onStop() {
        dispatchAppLifecycleEvent("mirrorTwinsAppStopped");
        if (webView != null) webView.pauseTimers();
        super.onStop();
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (webView != null) {
            webView.resumeTimers();
            webView.onResume();
            dispatchAppLifecycleEvent("mirrorTwinsAppResumed");
        }
        if (updateManager != null) updateManager.resumePendingInstallIfAllowed();
    }

    @Override
    protected void onDestroy() {
        dispatchAppLifecycleEvent("mirrorTwinsAppStopped");
        if (webView != null) {
            webView.stopLoading();
            webView.onPause();
        }
        super.onDestroy();
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
