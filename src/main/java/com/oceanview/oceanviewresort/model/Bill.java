package com.oceanview.oceanviewresort.model;


public class Bill {

    private int id;
    private int reservationId;
    private int guestId;
    private double amount;

    // Getters & Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getReservationId() { return reservationId; }
    public void setReservationId(int reservationId) { this.reservationId = reservationId; }

    public int getGuestId() { return guestId; }
    public void setGuestId(int guestId) { this.guestId = guestId; }

    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }
}