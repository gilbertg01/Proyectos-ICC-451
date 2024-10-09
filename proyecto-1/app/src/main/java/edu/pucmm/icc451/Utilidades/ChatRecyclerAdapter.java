package edu.pucmm.icc451.Utilidades;

import com.firebase.ui.database.FirebaseRecyclerAdapter;
import com.firebase.ui.database.FirebaseRecyclerOptions;
import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import edu.pucmm.icc451.Entidad.MensajeChat;
import edu.pucmm.icc451.R;

public class ChatRecyclerAdapter extends FirebaseRecyclerAdapter<MensajeChat, ChatRecyclerAdapter.ChatModelViewHolder> {

    Context context;

    public ChatRecyclerAdapter(@NonNull FirebaseRecyclerOptions<MensajeChat> options, Context context) {
        super(options);
        this.context = context;
    }

    @Override
    protected void onBindViewHolder(@NonNull ChatModelViewHolder holder, int position, @NonNull MensajeChat model) {
        Log.i("ChatAdapter", "Mensaje recibido");

        // Verificamos si el emisor es el usuario actual
        if (model.getEmisorId().equals(FirebaseUtil.currentUserId())) {
            holder.leftChatLayout.setVisibility(View.GONE);
            holder.rightChatLayout.setVisibility(View.VISIBLE);
            holder.rightChatTextview.setText(model.getMensaje());

            // Configuramos la hora del mensaje para el lado derecho
            if (model.getTemporal() instanceof Long) {
                String formattedDate = FirebaseUtil.timestampToString(model.getTemporal());
                holder.rightChatTime.setText(formattedDate);
            }
        }
        else {
            holder.rightChatLayout.setVisibility(View.GONE);
            holder.leftChatLayout.setVisibility(View.VISIBLE);
            holder.leftChatTextview.setText(model.getMensaje());

            // Configuramos la hora del mensaje para el lado izquierdo
            if (model.getTemporal() instanceof Long) {
                String formattedDate = FirebaseUtil.timestampToString(model.getTemporal());
                holder.leftChatTime.setText(formattedDate);
            }
        }
    }

    @NonNull
    @Override
    public ChatModelViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.message_recycle_row, parent, false);
        return new ChatModelViewHolder(view);
    }

    class ChatModelViewHolder extends RecyclerView.ViewHolder {
        LinearLayout leftChatLayout, rightChatLayout;
        TextView leftChatTextview, rightChatTextview;
        TextView leftChatTime, rightChatTime;

        public ChatModelViewHolder(@NonNull View itemView) {
            super(itemView);
            leftChatLayout = itemView.findViewById(R.id.left_chat_layout);
            rightChatLayout = itemView.findViewById(R.id.right_chat_layout);
            leftChatTextview = itemView.findViewById(R.id.left_chat_textview);
            rightChatTextview = itemView.findViewById(R.id.right_chat_textview);
            leftChatTime = itemView.findViewById(R.id.left_chat_time);
            rightChatTime = itemView.findViewById(R.id.right_chat_time);
        }
    }
}
