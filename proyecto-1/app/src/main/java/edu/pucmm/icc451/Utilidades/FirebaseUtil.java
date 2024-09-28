package edu.pucmm.icc451.Utilidades;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import java.util.Objects;


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
}










