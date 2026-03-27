/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.oceanview.oceanviewresort.util;

import java.security.MessageDigest;

public class PasswordUtil {

    public static String hashPassword(String password) {

        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());

            StringBuilder hex = new StringBuilder();

            for(byte b : hash){
                String s = Integer.toHexString(0xff & b);
                if(s.length() == 1) hex.append('0');
                hex.append(s);
            }

            return hex.toString();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }
    
    
    /*
    * Validates the strength of a given password.
    * 
    * Rules enforced:
    * - Password length must be between 6 and 15 characters.
    * - Must contain at least one uppercase letter (A-Z).
    * - Must contain at least one lowercase letter (a-z).
    * - Must contain at least one numeric digit (0-9).
    * - Must contain at least one special character (!@#$%^&*()).
    * 
    * Returns:
    * - true  → if all validation rules are satisfied
    * - false → if any rule is violated
    */
    public static boolean isValidPassword(String password) {

        if (password.length() < 6 || password.length() > 15) return false;

        boolean hasUpper = password.matches(".*[A-Z].*");
        boolean hasLower = password.matches(".*[a-z].*");
        boolean hasNumber = password.matches(".*\\d.*");
        boolean hasSpecial = password.matches(".*[!@#$%^&*()].*");

        return hasUpper && hasLower && hasNumber && hasSpecial;
    }
}

