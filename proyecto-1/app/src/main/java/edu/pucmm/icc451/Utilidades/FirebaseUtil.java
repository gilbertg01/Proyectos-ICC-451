package edu.pucmm.icc451.Utilidades;

import android.annotation.SuppressLint;
import android.content.Intent;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.firestore.Query;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Objects;

import edu.pucmm.icc451.Entidad.Usuario;


public class FirebaseUtil {

    public static String currentUserId(){
        return FirebaseAuth.getInstance().getUid();
    }

    public static boolean isLoggedIn(){
        return currentUserId() != null;
    }

    public static DatabaseReference currentUserDetails() {
        String currentUserId = Objects.requireNonNull(FirebaseAuth.getInstance().getCurrentUser()).getUid();
        return FirebaseDatabase.getInstance().getReference("users").child(currentUserId);
    }

    public static DatabaseReference allUserCollectionReference() {
        return FirebaseDatabase.getInstance().getReference("users");
    }

    public static DatabaseReference getUserReference(String userId) {
        return FirebaseDatabase.getInstance().getReference("users").child(userId);
    }

    public static DatabaseReference getChatReference(String chatId) {
        return FirebaseDatabase.getInstance().getReference("chat").child(chatId);
    }

    public static DatabaseReference getMensajeReference(String chatId){
        return FirebaseDatabase.getInstance().getReference("mensajes").child(chatId);
    }

    public static String getChatId(String userId1,String userId2){
        if(userId1.hashCode()<userId2.hashCode()){
            return userId1+"_"+userId2;
        }
        else{
            return userId2+"_"+userId1;
        }
    }

    public static DatabaseReference getOtherUserFromChatroom(List<String> userIds) {
        DatabaseReference userRef = FirebaseDatabase.getInstance().getReference("users");
        if (userIds.get(0).equals(FirebaseUtil.currentUserId())) {
            return userRef.child(userIds.get(1));  // Retorna referencia del otro usuario
        } else {
            return userRef.child(userIds.get(0));  // Retorna referencia del otro usuario
        }
    }

    @SuppressLint("SimpleDateFormat")
    public static String timestampToString(Object timestamp) {
        if (timestamp instanceof Long) {
            long time = (Long) timestamp;
            return new SimpleDateFormat("HH:mm").format(new Date(time));
        }
        return "";
    }

    public static DatabaseReference allChatsCollectionReference() {
        return FirebaseDatabase.getInstance().getReference("chat");
    }
}










