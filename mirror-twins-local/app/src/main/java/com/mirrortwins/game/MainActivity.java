package com.mirrortwins.game;

import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.TextView;

public class MainActivity extends Activity {
    private WebView webView;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        try {
            Window window = getWindow();
            window.setStatusBarColor(Color.rgb(8, 16, 36));
            window.setNavigationBarColor(Color.rgb(8, 16, 36));
            window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);

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

            webView.setWebViewClient(new WebViewClient());
            webView.setWebChromeClient(new WebChromeClient());
            webView.loadUrl("file:///android_asset/www/index.html");
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
        error.setText("Mirror Twins could not open the local game.\n\n" +
                t.getClass().getSimpleName() + ": " + String.valueOf(t.getMessage()) +
                "\n\nThis build does not require internet or a VPS.");
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
        if (webView != null && webView.canGoBack()) webView.goBack();
        else super.onBackPressed();
    }
}
