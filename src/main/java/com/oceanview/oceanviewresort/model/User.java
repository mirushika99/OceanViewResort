/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.oceanview.oceanviewresort.model;


public class User {

    private int id;
    private Integer guestId; // nullable
    private String email;
    private String password;
    private String role;
    private String firstName;
    
    

    // Getters & Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Integer getGuestId() { return guestId; }
    public void setGuestId(Integer guestId) { this.guestId = guestId; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    
    public String getFirstName(){ return firstName;}
    public void setFirstName(String firstName) {this.firstName=firstName;}
}