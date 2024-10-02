package edu.pucmm.icc451.Utilidades;

import android.content.Intent;

import edu.pucmm.icc451.Entidad.Usuario;

public class AndroidUtil {

    public static void passUserModelAsIntent(Intent intent, Usuario model){
        intent.putExtra("username",model.getUsername());
        intent.putExtra("email",model.getEmail());
        intent.putExtra("userId",model.getId());
    }

    public static Usuario getUserModelFromIntent(Intent intent) {
        Usuario user = new Usuario();
        user.setUsername(intent.getStringExtra("username"));
        user.setEmail(intent.getStringExtra("email"));
        user.setId(intent.getStringExtra("userId"));
        return user;
    }
}