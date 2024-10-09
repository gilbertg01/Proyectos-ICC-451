package edu.pucmm.icc451.Utilidades;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.firebase.ui.database.FirebaseRecyclerAdapter;
import com.firebase.ui.database.FirebaseRecyclerOptions;
import com.google.firebase.auth.FirebaseAuth;

import java.util.List;

import edu.pucmm.icc451.ChatActivity;
import edu.pucmm.icc451.Entidad.Usuario;
import edu.pucmm.icc451.R;

public class SearchUserRecyclerAdapter extends RecyclerView.Adapter<SearchUserRecyclerAdapter.UserModelViewHolder> {

    Context context;
    List<Usuario> userList;

    public SearchUserRecyclerAdapter(List<Usuario> userList, Context context) {
        this.userList = userList;
        this.context = context;
    }

    @Override
    public void onBindViewHolder(@NonNull UserModelViewHolder holder, int position) {
        Usuario model = userList.get(position);
        holder.usernameText.setText(model.getUsername());
        holder.emailText.setText(model.getEmail());

        if (model.getId().equals(FirebaseAuth.getInstance().getUid())) {
            holder.usernameText.setText(model.getUsername() + " (Me)");
        }

        holder.itemView.setOnClickListener(v -> {
            Intent intent = new Intent(context, ChatActivity.class);
            AndroidUtil.passUserModelAsIntent(intent, model);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
        });
    }

    @Override
    public int getItemCount() {
        return userList.size();
    }

    @NonNull
    @Override
    public UserModelViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.search_user_recycler_row, parent, false);
        return new UserModelViewHolder(view);
    }

    public class UserModelViewHolder extends RecyclerView.ViewHolder {
        TextView usernameText;
        TextView emailText;

        public UserModelViewHolder(@NonNull View itemView) {
            super(itemView);
            usernameText = itemView.findViewById(R.id.user_name_text);
            emailText = itemView.findViewById(R.id.email_text);
        }
    }
}

