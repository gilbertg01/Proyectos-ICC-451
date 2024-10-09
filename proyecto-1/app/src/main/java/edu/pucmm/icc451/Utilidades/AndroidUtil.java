package edu.pucmm.icc451.Utilidades;

import android.content.Intent;

import edu.pucmm.icc451.Entidad.Usuario;

public class AndroidUtil {

    public static void passUserModelAsIntent(Intent intent, Usuario model){
        intent.putExtra("username",model.getUsername());
        intent.putExtra("email",model.getEmail());
        intent.putExtra("userId",model.getId());
        intent.putExtra("fcmToken",model.getFcmToken());
        intent.putExtra("enLinea",model.isEnLinea());
    }

    public static Usuario getUserModelFromIntent(Intent intent) {
        Usuario user = new Usuario();
        user.setUsername(intent.getStringExtra("username"));
        user.setEmail(intent.getStringExtra("email"));
        user.setId(intent.getStringExtra("userId"));
        user.setFcmToken(intent.getStringExtra("fcmToken"));
        user.setEnLinea(intent.getBooleanExtra("enLinea",false));
        return user;
    }
}