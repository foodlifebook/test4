package com.mirrortwins.game;

import android.app.Activity;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.TextView;

public class MainActivity extends Activity {
    private static final String LOCAL_URL = "file:///android_asset/www/index.html";
    private static final String ONLINE_HOST = "mt.grafixers.co.uk";
    private WebView webView;
    private boolean returningToLocal = false;

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

            webView.setWebViewClient(new WebViewClient() {
                @Override
                public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
                    super.onReceivedError(view, request, error);
                    if (request != null && request.isForMainFrame()) {
                        Uri url = request.getUrl();
                        if (url != null && ONLINE_HOST.equalsIgnoreCase(url.getHost()) && !returningToLocal) {
                            returningToLocal = true;
                            view.loadUrl(LOCAL_URL + "?online=unavailable");
                        }
                    }
                }

                @Override
                public void onPageFinished(WebView view, String url) {
                    super.onPageFinished(view, url);
                    if (url != null && url.startsWith("file:///android_asset/")) {
                        returningToLocal = false;
                    }
                }
            });

            webView.setWebChromeClient(new WebChromeClient());
            webView.loadUrl(LOCAL_URL);
        } catch (Throwable t) {
            showStartupError(t);
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
                "\n\nSolo mode is stored on this device and works without internet.");
        setContentView(error);
    }

    @Override
    protected void onPause() {
        if (webView != null) webView.onPause();
        super.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (webView != null) webView.onResume();
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
