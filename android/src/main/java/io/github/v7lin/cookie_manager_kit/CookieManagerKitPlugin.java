package io.github.v7lin.cookie_manager_kit;

import android.content.Context;
import android.os.Build;
import android.text.TextUtils;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.ValueCallback;

import androidx.annotation.NonNull;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * CookieManagerKitPlugin
 */
public class CookieManagerKitPlugin implements FlutterPlugin, MethodCallHandler {
    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    public static void registerWith(Registrar registrar) {
        final CookieManagerKitPlugin instance = new CookieManagerKitPlugin();
        instance.onAttachedToEngine(registrar.context(), registrar.messenger());
    }

    private static final String METHOD_SAVECOOKIES = "saveCookies";
    private static final String METHOD_LOADCOOKIES = "loadCookies";
    private static final String METHOD_REMOVEALLCOOKIES = "removeAllCookies";

    private static final String ARGUMENT_KEY_URL = "url";
    private static final String ARGUMENT_KEY_COOKIES = "cookies";

    private Context applicationContext;
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
    }

    private void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
        this.applicationContext = applicationContext;
        channel = new MethodChannel(messenger, "v7lin.github.io/cookie_manager_kit");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        applicationContext = null;
        channel.setMethodCallHandler(null);
        channel = null;
    }

    // --- MethodCallHandler

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (METHOD_SAVECOOKIES.equals(call.method)) {
            saveCookies(call, result);
        } else if (METHOD_LOADCOOKIES.equals(call.method)) {
            loadCookies(call, result);
        } else if (METHOD_REMOVEALLCOOKIES.equals(call.method)) {
            removeAllCookies(call, result);
        } else {
            result.notImplemented();
        }
    }

    private void saveCookies(MethodCall call, Result result) {
        String url = call.argument(ARGUMENT_KEY_URL);
        List<String> cookies = call.argument(ARGUMENT_KEY_COOKIES);
        if (cookies != null && !cookies.isEmpty()) {
            try {
                CookieSyncManager.createInstance(applicationContext);
                for (String cookie : cookies) {
                    CookieManager.getInstance().setCookie(url, cookie);
                }
            } finally {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    CookieManager.getInstance().flush();
                } else {
                    CookieSyncManager.getInstance().sync();
                }
            }
        }
        result.success(null);
    }

    private void loadCookies(MethodCall call, Result result) {
        String url = call.argument(ARGUMENT_KEY_URL);
        CookieSyncManager.createInstance(applicationContext);
        String cookieStrAll = CookieManager.getInstance().getCookie(url);
        if (!TextUtils.isEmpty(cookieStrAll)) {
            String[] cookies = cookieStrAll.split("; ");
            result.success(Collections.unmodifiableList(Arrays.asList(cookies)));
        } else {
            result.success(Collections.emptyList());
        }
    }

    private void removeAllCookies(MethodCall call, Result result) {
        try {
            CookieSyncManager.createInstance(applicationContext);
            CookieManager.getInstance().removeAllCookie();
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                CookieManager.getInstance().removeAllCookies(new ValueCallback<Boolean>() {
                    @Override
                    public void onReceiveValue(Boolean value) {
                    }
                });
            } else {
                CookieManager.getInstance().removeAllCookie();
            }
        } finally {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                CookieManager.getInstance().flush();
            } else {
                CookieSyncManager.getInstance().sync();
            }
        }
        result.success(null);
    }
}
