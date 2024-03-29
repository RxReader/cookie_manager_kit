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
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * CookieManagerKitPlugin
 */
public class CookieManagerKitPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private Context applicationContext;

    // -- FlutterPlugin

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "v7lin.github.io/cookie_manager_kit");
        channel.setMethodCallHandler(this);
        applicationContext = binding.getApplicationContext();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
        applicationContext = null;
    }

    // --- MethodCallHandler

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if ("saveCookies".equals(call.method)) {
            saveCookies(call, result);
        } else if ("loadCookies".equals(call.method)) {
            loadCookies(call, result);
        } else if ("removeAllCookies".equals(call.method)) {
            removeAllCookies(call, result);
        } else {
            result.notImplemented();
        }
    }

    private void saveCookies(@NonNull MethodCall call, @NonNull Result result) {
        final String url = call.argument("url");
        final List<String> cookies = call.argument("cookies");
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

    private void loadCookies(@NonNull MethodCall call, @NonNull Result result) {
        final String url = call.argument("url");
        CookieSyncManager.createInstance(applicationContext);
        final String cookieStrAll = CookieManager.getInstance().getCookie(url);
        if (!TextUtils.isEmpty(cookieStrAll)) {
            final String[] cookies = cookieStrAll.split("; ");
            result.success(Collections.unmodifiableList(Arrays.asList(cookies)));
        } else {
            result.success(Collections.emptyList());
        }
    }

    private void removeAllCookies(@NonNull MethodCall call, @NonNull Result result) {
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
