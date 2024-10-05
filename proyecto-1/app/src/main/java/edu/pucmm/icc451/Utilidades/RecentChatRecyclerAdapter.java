package edu.pucmm.icc451.Utilidades;

import android.content.Context;
import android.content.Intent;
import com.firebase.ui.database.FirebaseRecyclerAdapter;
import com.firebase.ui.database.FirebaseRecyclerOptions;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import edu.pucmm.icc451.ChatActivity;
import edu.pucmm.icc451.Entidad.Chat;
import edu.pucmm.icc451.Entidad.Usuario;
import edu.pucmm.icc451.R;

public class RecentChatRecyclerAdapter extends FirebaseRecyclerAdapter<Chat, RecentChatRecyclerAdapter.ChatViewHolder> {

    Context context;

    public RecentChatRecyclerAdapter(@NonNull FirebaseRecyclerOptions<Chat> options, Context context) {
        super(options);
        this.context = context;
    }

    @Override
    protected void onBindViewHolder(@NonNull ChatViewHolder holder, int position, @NonNull Chat chat) {
        // Obteniendo los otros usuarios desde Realtime Database
        FirebaseUtil.getOtherUserFromChatroom(chat.getUserIds())
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snapshot) {
                        Usuario otherUsuario = snapshot.getValue(Usuario.class);

                        boolean lastMessageSentByMe = chat.getUltimoEnvioId().equals(FirebaseUtil.currentUserId());

                        assert otherUsuario != null;
                        holder.usernameText.setText(otherUsuario.getUsername());
                        if (lastMessageSentByMe) {
                            holder.lastMessageText.setText("Tu: " + chat.getUltimoMensajeStr());
                        } else {
                            holder.lastMessageText.setText(chat.getUltimoMensajeStr());
                        }
                        holder.lastMessageTime.setText(FirebaseUtil.timestampToString(chat.getUltimoMensaje()));

                        // Configurando click listener
                        holder.itemView.setOnClickListener(v -> {
                            Intent intent = new Intent(context, ChatActivity.class);
                            AndroidUtil.passUserModelAsIntent(intent, otherUsuario);
                            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                            context.startActivity(intent);
                        });
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError error) {
                        // Manejo de errores
                    }
                });
    }

    @NonNull
    @Override
    public ChatViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.lista_chats_recycler_view, parent, false);
        return new ChatViewHolder(view);
    }

    static class ChatViewHolder extends RecyclerView.ViewHolder {
        TextView usernameText;
        TextView lastMessageText;
        TextView lastMessageTime;

        public ChatViewHolder(@NonNull View itemView) {
            super(itemView);
            usernameText = itemView.findViewById(R.id.user_name_text);
            lastMessageText = itemView.findViewById(R.id.last_message_text);
            lastMessageTime = itemView.findViewById(R.id.last_message_time_text);
        }
    }
}