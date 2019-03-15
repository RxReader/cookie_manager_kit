package io.github.v7lin.fakecookiemanager;

import android.os.Build;
import android.text.TextUtils;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.ValueCallback;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FakeCookieManagerPlugin
 */
@SuppressWarnings("deprecation")
public class FakeCookieManagerPlugin implements MethodCallHandler {
    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "v7lin.github.io/fake_cookie_manager");
        FakeCookieManagerPlugin plugin = new FakeCookieManagerPlugin(registrar);
        channel.setMethodCallHandler(plugin);
    }

    private static final  String METHOD_SAVECOOKIES = "saveCookies";
    private static final  String METHOD_LOADCOOKIES = "loadCookies";
    private static final  String METHOD_REMOVEALLCOOKIES = "removeAllCookies";

    private static final String ARGUMENT_KEY_URL = "url";
    private static final String ARGUMENT_KEY_COOKIES = "cookies";

    private final Registrar registrar;

    private FakeCookieManagerPlugin(Registrar registrar) {
        this.registrar = registrar;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
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
                CookieSyncManager.createInstance(registrar.context());
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
        CookieSyncManager.createInstance(registrar.context());
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
            CookieSyncManager.createInstance(registrar.context());
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
