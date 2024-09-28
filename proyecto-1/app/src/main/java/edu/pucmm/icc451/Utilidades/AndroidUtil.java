package edu.pucmm.icc451.Utilidades;

import android.content.Intent;

public class AndroidUtil {

    public static void passUserModelAsIntent(Intent intent, Usuario model){
        intent.putExtra("username",model.getUsername());
        intent.putExtra("email",model.getEmail());
        intent.putExtra("userId",model.getId());
    }
}