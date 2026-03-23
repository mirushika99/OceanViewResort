/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Test;

import com.oceanview.oceanviewresort.util.PasswordUtil;

public class PasswordHash {

    public static void main(String[] args) {

        String hashed = PasswordUtil.hashPassword("Admin@123");

        System.out.println("Hashed Password: " + hashed);
    }
}