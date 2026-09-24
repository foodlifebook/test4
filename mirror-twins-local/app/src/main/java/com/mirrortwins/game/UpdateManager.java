package com.mirrortwins.game;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.widget.Toast;

import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.MessageDigest;
import java.util.Locale;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

public final class UpdateManager {
    public static final String BASE_URL = "https://mt.grafixers.co.uk";
    public static final String GAME_MANIFEST = BASE_URL + "/updates/game.json";
    public static final String APP_MANIFEST = BASE_URL + "/updates/android.json";
    public static final int BUNDLED_GAME_VERSION_CODE = 1;
    public static final String BUNDLED_GAME_VERSION_NAME = "1.0.0-bundled";

    private static final String PREFS = "mirror_twins_updater";
    private static final String KEY_GAME_CODE = "game_code";
    private static final String KEY_GAME_NAME = "game_name";
    private static final String KEY_SKIP_GAME = "skip_game_code";
    private static final String KEY_SKIP_APP = "skip_app_code";

    private final Activity activity;
    private final Runnable reloadGame;
    private final SharedPreferences prefs;
    private File pendingApk;
    private volatile boolean updateStatusChecked = false;
    private volatile boolean gameUpdateAvailable = false;
    private volatile boolean appUpdateAvailable = false;
    private volatile String remoteGameVersion = "";
    private volatile String remoteAppVersion = "";

    public UpdateManager(Activity activity, Runnable reloadGame) {
        this.activity = activity;
        this.reloadGame = reloadGame;
        this.prefs = activity.getSharedPreferences(PREFS, Activity.MODE_PRIVATE);
    }

    public String getGameEntryUrl() {
        File current = new File(activity.getFilesDir(), "game-current");
        File previous = new File(activity.getFilesDir(), "game-previous");

        if (!isValidGame(current) && isValidGame(previous)) {
            deleteRecursively(current);
            if (previous.renameTo(current)) {
                prefs.edit()
                        .putInt(KEY_GAME_CODE, BUNDLED_GAME_VERSION_CODE)
                        .putString(KEY_GAME_NAME, "Recovered")
                        .apply();
            }
        }

        File index = new File(current, "index.html");
        if (index.isFile()) {
            return Uri.fromFile(index).toString();
        }
        return "file:///android_asset/www/index.html";
    }

    public String getGameVersionName() {
        return prefs.getString(KEY_GAME_NAME, BUNDLED_GAME_VERSION_NAME);
    }

    public int getGameVersionCode() {
        return prefs.getInt(KEY_GAME_CODE, BUNDLED_GAME_VERSION_CODE);
    }

    public String getAppVersionName() {
        try {
            String name = activity.getPackageManager()
                    .getPackageInfo(activity.getPackageName(), 0).versionName;
            return name == null ? "Unknown" : name;
        } catch (Exception e) {
            return "Unknown";
        }
    }

    public int getAppVersionCode() {
        try {
            android.content.pm.PackageInfo info = activity.getPackageManager()
                    .getPackageInfo(activity.getPackageName(), 0);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                long code = info.getLongVersionCode();
                return code > Integer.MAX_VALUE ? Integer.MAX_VALUE : (int) code;
            }
            return info.versionCode;
        } catch (Exception e) {
            return 0;
        }
    }

    public void checkForUpdates(boolean manual) {
        if (manual) {
            Toast.makeText(activity, "Checking for updates…", Toast.LENGTH_SHORT).show();
        }

        new Thread(() -> {
            JSONObject game = fetchJson(GAME_MANIFEST);
            JSONObject app = fetchJson(APP_MANIFEST);

            gameUpdateAvailable = isGameNewer(game);
            appUpdateAvailable = isAppNewer(app);
            remoteGameVersion = game == null ? "" : game.optString("versionName", "");
            remoteAppVersion = app == null ? "" : app.optString("versionName", "");
            updateStatusChecked = true;

            activity.runOnUiThread(() -> {
                if (manual) {
                    handleUpdateCheck(game, app, true);
                }
            });
        }, "MirrorTwins-UpdateCheck").start();
    }

    private void handleUpdateCheck(JSONObject game, JSONObject app, boolean manual) {
        boolean gameAvailable = isGameUpdateAvailable(game, manual);
        boolean appAvailable = isAppUpdateAvailable(app, manual);

        if (gameAvailable) {
            showGameUpdateDialog(game, app, manual);
            return;
        }
        if (appAvailable) {
            showAppUpdateDialog(app);
            return;
        }
        if (manual) {
            Toast.makeText(activity,
                    "You already have the latest available Mirror Twins updates.",
                    Toast.LENGTH_LONG).show();
        }
    }

    private boolean isGameNewer(JSONObject manifest) {
        if (manifest == null) return false;
        return manifest.optInt("versionCode", -1) > getGameVersionCode();
    }

    private boolean isAppNewer(JSONObject manifest) {
        if (manifest == null) return false;
        return manifest.optInt("versionCode", -1) > getAppVersionCode();
    }

    private boolean isGameUpdateAvailable(JSONObject manifest, boolean manual) {
        if (!isGameNewer(manifest)) return false;
        int code = manifest.optInt("versionCode", -1);
        return manual || code != prefs.getInt(KEY_SKIP_GAME, -1);
    }

    private boolean isAppUpdateAvailable(JSONObject manifest, boolean manual) {
        if (!isAppNewer(manifest)) return false;
        int code = manifest.optInt("versionCode", -1);
        return manual || code != prefs.getInt(KEY_SKIP_APP, -1);
    }

    public String getUpdateStatusJson() {
        JSONObject out = new JSONObject();
        try {
            out.put("checked", updateStatusChecked);
            out.put("game", gameUpdateAvailable);
            out.put("app", appUpdateAvailable);
            out.put("available", gameUpdateAvailable || appUpdateAvailable);
            out.put("remoteGameVersion", remoteGameVersion);
            out.put("remoteAppVersion", remoteAppVersion);
        } catch (Exception ignored) {
        }
        return out.toString();
    }

    private void showGameUpdateDialog(JSONObject manifest, JSONObject appManifest, boolean manual) {
        int code = manifest.optInt("versionCode", -1);
        String name = manifest.optString("versionName", "New game version");
        String notes = manifest.optString("notes", "New game content is available.");

        new AlertDialog.Builder(activity)
                .setTitle("Game Update Available")
                .setMessage(name + "\n\n" + notes +
                        "\n\nUpdating is optional. You can keep playing your current version.")
                .setPositiveButton("Update Game", (d, w) -> downloadGameUpdate(manifest))
                .setNegativeButton("Later", (d, w) -> {
                    prefs.edit().putInt(KEY_SKIP_GAME, code).apply();
                    if (isAppUpdateAvailable(appManifest, manual)) {
                        showAppUpdateDialog(appManifest);
                    }
                })
                .setNeutralButton("Skip This Version", (d, w) ->
                        prefs.edit().putInt(KEY_SKIP_GAME, code).apply())
                .show();
    }

    private void showAppUpdateDialog(JSONObject manifest) {
        int code = manifest.optInt("versionCode", -1);
        String name = manifest.optString("versionName", "New app version");
        String notes = manifest.optString("notes", "A new Android app version is available.");

        new AlertDialog.Builder(activity)
                .setTitle("App Update Available")
                .setMessage(name + "\n\n" + notes +
                        "\n\nUpdating is optional. The current app will continue to work.")
                .setPositiveButton("Download APK", (d, w) -> downloadAppUpdate(manifest))
                .setNegativeButton("Later", (d, w) ->
                        prefs.edit().putInt(KEY_SKIP_APP, code).apply())
                .setNeutralButton("Skip This Version", (d, w) ->
                        prefs.edit().putInt(KEY_SKIP_APP, code).apply())
                .show();
    }

    private void downloadGameUpdate(JSONObject manifest) {
        String url = manifest.optString("url", "");
        String sha = manifest.optString("sha256", "");
        int code = manifest.optInt("versionCode", -1);
        String name = manifest.optString("versionName", "Updated");

        if (!isTrustedHttps(url) || sha.length() < 32 || code < 0) {
            showError("This game update manifest is incomplete or unsafe.");
            return;
        }

        ProgressDialog progress = new ProgressDialog(activity);
        progress.setTitle("Updating Mirror Twins");
        progress.setMessage("Downloading and verifying the game update…");
        progress.setCancelable(false);
        progress.show();

        new Thread(() -> {
            File zip = new File(activity.getCacheDir(), "mirror-twins-game-update.zip");
            try {
                download(url, zip, 150L * 1024L * 1024L);
                verifySha256(zip, sha);
                installGameZip(zip);

                prefs.edit()
                        .putInt(KEY_GAME_CODE, code)
                        .putString(KEY_GAME_NAME, name)
                        .remove(KEY_SKIP_GAME)
                        .apply();

                activity.runOnUiThread(() -> {
                    progress.dismiss();
                    gameUpdateAvailable = false;
                    Toast.makeText(activity, "Game update installed.", Toast.LENGTH_LONG).show();
                    reloadGame.run();
                });
            } catch (Exception e) {
                activity.runOnUiThread(() -> {
                    progress.dismiss();
                    showError("Game update failed. Your previous version is still available.\n\n" +
                            safeMessage(e));
                });
            } finally {
                //noinspection ResultOfMethodCallIgnored
                zip.delete();
            }
        }, "MirrorTwins-GameUpdate").start();
    }

    private void downloadAppUpdate(JSONObject manifest) {
        String url = manifest.optString("apk", manifest.optString("url", ""));
        String sha = manifest.optString("sha256", "");

        if (!isTrustedHttps(url) || sha.length() < 32) {
            showError("This Android update manifest is incomplete or unsafe.");
            return;
        }

        ProgressDialog progress = new ProgressDialog(activity);
        progress.setTitle("Downloading App Update");
        progress.setMessage("Downloading and verifying the APK…");
        progress.setCancelable(false);
        progress.show();

        new Thread(() -> {
            File apk = new File(activity.getCacheDir(), "mirror-twins-update.apk");
            try {
                download(url, apk, 250L * 1024L * 1024L);
                verifySha256(apk, sha);
                pendingApk = apk;

                activity.runOnUiThread(() -> {
                    progress.dismiss();
                    beginApkInstall();
                });
            } catch (Exception e) {
                activity.runOnUiThread(() -> {
                    progress.dismiss();
                    showError("App update download failed.\n\n" + safeMessage(e));
                });
            }
        }, "MirrorTwins-AppUpdate").start();
    }

    public void resumePendingInstallIfAllowed() {
        if (pendingApk != null && pendingApk.isFile()) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O ||
                    activity.getPackageManager().canRequestPackageInstalls()) {
                installApk(pendingApk);
            }
        }
    }

    private void beginApkInstall() {
        if (pendingApk == null || !pendingApk.isFile()) return;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                !activity.getPackageManager().canRequestPackageInstalls()) {
            new AlertDialog.Builder(activity)
                    .setTitle("Allow Mirror Twins Updates")
                    .setMessage("Android requires permission to install an APK downloaded by Mirror Twins. " +
                            "You can cancel and keep using the current version.")
                    .setPositiveButton("Open Settings", (d, w) -> {
                        Intent intent = new Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                                Uri.parse("package:" + activity.getPackageName()));
                        activity.startActivity(intent);
                    })
                    .setNegativeButton("Cancel", null)
                    .show();
            return;
        }

        installApk(pendingApk);
    }

    private void installApk(File apk) {
        Uri uri = Uri.parse("content://" + activity.getPackageName() + ".apkprovider/update.apk");
        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setDataAndType(uri, "application/vnd.android.package-archive");
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_ACTIVITY_NEW_TASK);
        activity.startActivity(intent);
    }

    public boolean rollbackGame() {
        File current = new File(activity.getFilesDir(), "game-current");
        File previous = new File(activity.getFilesDir(), "game-previous");
        if (!isValidGame(previous)) return false;

        File broken = new File(activity.getFilesDir(), "game-broken");
        deleteRecursively(broken);
        if (current.exists()) {
            //noinspection ResultOfMethodCallIgnored
            current.renameTo(broken);
        }
        boolean restored = previous.renameTo(current);
        deleteRecursively(broken);

        if (restored) {
            prefs.edit()
                    .putInt(KEY_GAME_CODE, BUNDLED_GAME_VERSION_CODE)
                    .putString(KEY_GAME_NAME, "Recovered")
                    .apply();
        }
        return restored;
    }

    private void installGameZip(File zip) throws Exception {
        File next = new File(activity.getFilesDir(), "game-next");
        File current = new File(activity.getFilesDir(), "game-current");
        File previous = new File(activity.getFilesDir(), "game-previous");

        deleteRecursively(next);
        if (!next.mkdirs() && !next.isDirectory()) {
            throw new Exception("Could not create update staging directory.");
        }

        unzipSafely(zip, next);

        File staged = next;
        if (!new File(staged, "index.html").isFile()) {
            File www = new File(next, "www");
            if (new File(www, "index.html").isFile()) {
                staged = www;
            }
        }
        if (!new File(staged, "index.html").isFile()) {
            deleteRecursively(next);
            throw new Exception("Update package does not contain index.html.");
        }

        deleteRecursively(previous);
        boolean hadCurrent = current.exists();
        if (hadCurrent && !current.renameTo(previous)) {
            deleteRecursively(next);
            throw new Exception("Could not preserve the current game version.");
        }

        if (!staged.renameTo(current)) {
            if (hadCurrent && previous.exists()) {
                //noinspection ResultOfMethodCallIgnored
                previous.renameTo(current);
            }
            deleteRecursively(next);
            throw new Exception("Could not activate the downloaded game version.");
        }

        deleteRecursively(next);

        if (!isValidGame(current)) {
            deleteRecursively(current);
            if (previous.exists()) {
                //noinspection ResultOfMethodCallIgnored
                previous.renameTo(current);
            }
            throw new Exception("Downloaded game failed validation.");
        }
    }

    private JSONObject fetchJson(String address) {
        HttpURLConnection connection = null;
        try {
            URL url = new URL(address);
            connection = (HttpURLConnection) url.openConnection();
            connection.setConnectTimeout(7000);
            connection.setReadTimeout(7000);
            connection.setRequestProperty("User-Agent", "MirrorTwins-Android-Updater/" + getAppVersionName());
            connection.setUseCaches(false);
            int status = connection.getResponseCode();
            if (status < 200 || status >= 300) return null;

            InputStream input = new BufferedInputStream(connection.getInputStream());
            byte[] buffer = new byte[4096];
            StringBuilder out = new StringBuilder();
            int read;
            while ((read = input.read(buffer)) != -1) {
                out.append(new String(buffer, 0, read, "UTF-8"));
                if (out.length() > 256 * 1024) return null;
            }
            input.close();
            return new JSONObject(out.toString());
        } catch (Exception ignored) {
            return null;
        } finally {
            if (connection != null) connection.disconnect();
        }
    }

    private void download(String address, File output, long maxBytes) throws Exception {
        HttpURLConnection connection = null;
        try {
            URL url = new URL(address);
            connection = (HttpURLConnection) url.openConnection();
            connection.setConnectTimeout(10000);
            connection.setReadTimeout(20000);
            connection.setRequestProperty("User-Agent", "MirrorTwins-Android-Updater/" + getAppVersionName());
            connection.setInstanceFollowRedirects(true);

            int status = connection.getResponseCode();
            if (status < 200 || status >= 300) {
                throw new Exception("Server returned HTTP " + status);
            }

            long declared = connection.getContentLengthLong();
            if (declared > maxBytes) throw new Exception("Update file is too large.");

            try (InputStream in = new BufferedInputStream(connection.getInputStream());
                 FileOutputStream out = new FileOutputStream(output)) {
                byte[] buffer = new byte[8192];
                long total = 0;
                int read;
                while ((read = in.read(buffer)) != -1) {
                    total += read;
                    if (total > maxBytes) throw new Exception("Update exceeded the size limit.");
                    out.write(buffer, 0, read);
                }
                out.getFD().sync();
            }
        } finally {
            if (connection != null) connection.disconnect();
        }
    }

    private void verifySha256(File file, String expected) throws Exception {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        try (FileInputStream in = new FileInputStream(file)) {
            byte[] buffer = new byte[8192];
            int read;
            while ((read = in.read(buffer)) != -1) {
                digest.update(buffer, 0, read);
            }
        }

        StringBuilder actual = new StringBuilder();
        for (byte b : digest.digest()) {
            actual.append(String.format(Locale.US, "%02x", b & 0xff));
        }

        if (!actual.toString().equalsIgnoreCase(expected.trim())) {
            throw new Exception("SHA-256 verification failed.");
        }
    }

    private void unzipSafely(File zip, File destination) throws Exception {
        String root = destination.getCanonicalPath() + File.separator;

        try (ZipInputStream zin = new ZipInputStream(
                new BufferedInputStream(new FileInputStream(zip)))) {
            ZipEntry entry;
            while ((entry = zin.getNextEntry()) != null) {
                File out = new File(destination, entry.getName());
                String canonical = out.getCanonicalPath();
                if (!canonical.startsWith(root)) {
                    throw new Exception("Unsafe path in update package.");
                }

                if (entry.isDirectory()) {
                    if (!out.mkdirs() && !out.isDirectory()) {
                        throw new Exception("Could not create update directory.");
                    }
                } else {
                    File parent = out.getParentFile();
                    if (parent != null && !parent.mkdirs() && !parent.isDirectory()) {
                        throw new Exception("Could not create update directory.");
                    }
                    try (BufferedOutputStream fileOut =
                                 new BufferedOutputStream(new FileOutputStream(out))) {
                        byte[] buffer = new byte[8192];
                        int read;
                        while ((read = zin.read(buffer)) != -1) {
                            fileOut.write(buffer, 0, read);
                        }
                    }
                }
                zin.closeEntry();
            }
        }
    }

    private boolean isTrustedHttps(String address) {
        try {
            Uri uri = Uri.parse(address);
            return "https".equalsIgnoreCase(uri.getScheme()) &&
                    "mt.grafixers.co.uk".equalsIgnoreCase(uri.getHost());
        } catch (Exception e) {
            return false;
        }
    }

    private boolean isValidGame(File dir) {
        return dir.isDirectory() && new File(dir, "index.html").isFile();
    }

    private void deleteRecursively(File file) {
        if (file == null || !file.exists()) return;
        if (file.isDirectory()) {
            File[] children = file.listFiles();
            if (children != null) {
                for (File child : children) deleteRecursively(child);
            }
        }
        //noinspection ResultOfMethodCallIgnored
        file.delete();
    }

    private void showError(String message) {
        new AlertDialog.Builder(activity)
                .setTitle("Mirror Twins Update")
                .setMessage(message)
                .setPositiveButton("OK", null)
                .show();
    }

    private String safeMessage(Exception e) {
        String msg = e.getMessage();
        return msg == null || msg.trim().isEmpty() ? e.getClass().getSimpleName() : msg;
    }
}
