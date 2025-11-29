package bookstore;

import java.io. Serializable;

public class User implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private int userID;
    private String username;
    private String password;
    private String role;  // "student" or "admin"
    
    public User(int userID, String username, String password, String role) {
        this.userID = userID;
        this.username = username;
        this.password = password;
        this.role = role;
    }
    
    // Getters
    public int getUserID() {
        return userID;
    }
    
    public String getUsername() {
        return username;
    }
    
    public String getPassword() {
        return password;
    }
    
    public String getRole() {
        return role;
    }
    
    // Setters
    public void setUserID(int userID) {
        this.userID = userID;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
    
    public void setRole(String role) {
        this.role = role;
    }
    
    // Check if user is admin
    public boolean isAdmin() {
        return "admin".equalsIgnoreCase(role);
    }
    
    // Check if user is student
    public boolean isStudent() {
        return "student". equalsIgnoreCase(role);
    }
}
