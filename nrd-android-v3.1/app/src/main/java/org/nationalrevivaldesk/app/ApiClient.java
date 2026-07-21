package org.nationalrevivaldesk.app;

import android.content.Context;
import android.content.SharedPreferences;
import androidx.security.crypto.EncryptedSharedPreferences;
import androidx.security.crypto.MasterKey;
import org.json.JSONObject;
import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;

public final class ApiClient {
    private final String baseUrl;
    private final SharedPreferences prefs;
    public ApiClient(Context context) {
        baseUrl = context.getString(R.string.backend_url).replaceAll("/+$", "") + "/";
        SharedPreferences secure;
        try {
            MasterKey key = new MasterKey.Builder(context).setKeyScheme(MasterKey.KeyScheme.AES256_GCM).build();
            secure = EncryptedSharedPreferences.create(context,"nrd_secure",key,EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM);
        } catch (Exception error) {
            secure = context.getSharedPreferences("nrd_secure_fallback", Context.MODE_PRIVATE);
        }
        prefs = secure;
    }
    public String token(){ return prefs.getString("token", ""); }
    public void saveToken(String token){ prefs.edit().putString("token", token).apply(); }
    public void logout(){ prefs.edit().clear().apply(); }
    public JSONObject post(String endpoint, JSONObject body) throws Exception { return request("POST", endpoint, body); }
    public JSONObject get(String endpoint) throws Exception { return request("GET", endpoint, null); }
    private JSONObject request(String method,String endpoint,JSONObject body) throws Exception {
        URL url = new URL(baseUrl + endpoint);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        try {
            connection.setConnectTimeout(20000); connection.setReadTimeout(40000); connection.setRequestMethod(method);
            connection.setRequestProperty("Accept","application/json"); connection.setRequestProperty("User-Agent","NationalRevivalDesk-Android/3.3.0");
            if(!token().isEmpty()) connection.setRequestProperty("Authorization","Bearer " + token());
            if(body != null){ connection.setDoOutput(true); connection.setRequestProperty("Content-Type","application/json; charset=utf-8"); try(OutputStream output=connection.getOutputStream()){ output.write(body.toString().getBytes(StandardCharsets.UTF_8)); } }
            int status=connection.getResponseCode(); InputStream input=status>=400?connection.getErrorStream():connection.getInputStream(); String text=readAll(input); if(text==null||text.trim().isEmpty())text="{}"; JSONObject json=new JSONObject(text); if(status>=400)throw new IOException(json.optString("message","Server error "+status)); return json;
        } finally { connection.disconnect(); }
    }
    private static String readAll(InputStream input) throws IOException { if(input==null)return ""; try(BufferedReader reader=new BufferedReader(new InputStreamReader(input,StandardCharsets.UTF_8))){ StringBuilder result=new StringBuilder(); String line; while((line=reader.readLine())!=null)result.append(line); return result.toString(); } }
}
