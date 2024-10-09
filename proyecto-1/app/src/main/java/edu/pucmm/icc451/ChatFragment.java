package edu.pucmm.icc451;

import android.annotation.SuppressLint;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.firebase.ui.database.FirebaseRecyclerOptions;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;

import edu.pucmm.icc451.Entidad.Usuario;
import edu.pucmm.icc451.Utilidades.SearchUserRecyclerAdapter;

public class ChatFragment extends Fragment {

    RecyclerView recyclerView;
    SearchUserRecyclerAdapter adapter;

    public ChatFragment() {

    }
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_chat, container, false);
        recyclerView = view.findViewById(R.id.recycler_view);
        setupRecyclerView();
        return view;
    }

    void setupRecyclerView() {
        DatabaseReference usersRef = FirebaseDatabase.getInstance().getReference("users");
        String currentUserId = FirebaseAuth.getInstance().getUid(); // Obtener el ID del usuario actual

        usersRef.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                List<Usuario> filteredUserList = new ArrayList<>();

                for (DataSnapshot userSnapshot : snapshot.getChildren()) {
                    Usuario user = userSnapshot.getValue(Usuario.class);
                    if (user != null && !user.getId().equals(currentUserId)) {
                        filteredUserList.add(user);
                    }
                }

                // Configurar el adaptador con la lista filtrada de usuarios
                adapter = new SearchUserRecyclerAdapter(filteredUserList, getContext());
                recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
                recyclerView.setAdapter(adapter);
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                error.toException().printStackTrace();
            }
        });
    }
}

