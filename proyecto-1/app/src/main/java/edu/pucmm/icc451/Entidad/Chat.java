package edu.pucmm.icc451.Entidad;

import java.util.List;
import java.util.Map;

public class Chat {
    private String id;
    private List<String> userIds;
    private Map<String, String> ultimoMensaje;
    private String ultimoEnvioId;

    public Chat() {
    }

    public Chat(String id, List<String> userIds, Map<String, String> ultimoMensaje, String ultimoEnvioId) {
        this.id = id;
        this.userIds = userIds;
        this.ultimoMensaje = ultimoMensaje;
        this.ultimoEnvioId = ultimoEnvioId;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public List<String> getUserIds() {
        return userIds;
    }

    public void setUserIds(List<String> userIds) {
        this.userIds = userIds;
    }

    public Map<String, String> getUltimoMensaje() {
        return ultimoMensaje;
    }

    public void setUltimoMensaje(Map<String, String> ultimoMensaje) {
        this.ultimoMensaje = ultimoMensaje;
    }

    public String getUltimoEnvioId() {
        return ultimoEnvioId;
    }

    public void setUltimoEnvioId(String ultimoEnvioId) {
        this.ultimoEnvioId = ultimoEnvioId;
    }
}