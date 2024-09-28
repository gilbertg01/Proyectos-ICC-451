package edu.pucmm.icc451.Entidad;

public class Usuario {
    private String id;
    private String username;
    private String email;
    private String imageURL;

    public Usuario() {
    }

    public Usuario(String id, String username, String email, String imageURL) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.imageURL = imageURL;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getImageURL() {
        return imageURL;
    }

    public void setImageURL(String imageURL) {
        this.imageURL = imageURL;
    }
}

