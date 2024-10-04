package edu.pucmm.icc451.Entidad;

public class MensajeChat {
    private String mensaje;
    private String emisorId;
    private Object temporal;

    public MensajeChat() {
    }

    public MensajeChat(String mensaje, String emisorId, Object temporal) {
        this.mensaje = mensaje;
        this.emisorId = emisorId;
        this.temporal = temporal;
    }

    public String getMensaje() {
        return mensaje;
    }

    public void setMensaje(String mensaje) {
        this.mensaje = mensaje;
    }

    public String getEmisorId() {
        return emisorId;
    }

    public void setEmisorId(String emisorId) {
        this.emisorId = emisorId;
    }

    public Object getTemporal() {
        return temporal;
    }

    public void setTemporal(Object temporal) {
        this.temporal = temporal;
    }
}