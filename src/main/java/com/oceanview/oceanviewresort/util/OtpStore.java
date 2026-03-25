package com.oceanview.oceanviewresort.util;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Random;

/**
 * In-memory OTP store with 10-minute expiry.
 * Stores OTPs keyed by email address.
 * Thread-safe — uses ConcurrentHashMap.
 */
public class OtpStore {

    private static final long EXPIRY_MS = 10 * 60 * 1000L; // 10 minutes

    private static final Map<String, Entry> store = new ConcurrentHashMap<>();
    private static final Random random = new Random();

    // ── Generate and store a new 6-digit OTP for an email ────────────────────
    public static String generateOtp(String email) {
        String otp = String.format("%06d", random.nextInt(1_000_000));
        store.put(email.toLowerCase(), new Entry(otp, System.currentTimeMillis()));
        return otp;
    }

    // ── Verify OTP — returns true and removes it if valid ────────────────────
    public static boolean verify(String email, String otp) {
        Entry entry = store.get(email.toLowerCase());
        if (entry == null)
            return false;

        boolean expired = (System.currentTimeMillis() - entry.createdAt) > EXPIRY_MS;
        boolean matches = entry.otp.equals(otp.trim());

        if (expired) {
            store.remove(email.toLowerCase());
            return false;
        }

        if (matches) {
            store.remove(email.toLowerCase()); // one-time use
            return true;
        }

        return false;
    }

    // ── Check if a pending OTP exists for this email ──────────────────────────
    public static boolean hasPending(String email) {
        Entry entry = store.get(email.toLowerCase());
        if (entry == null)
            return false;
        if ((System.currentTimeMillis() - entry.createdAt) > EXPIRY_MS) {
            store.remove(email.toLowerCase());
            return false;
        }
        return true;
    }

    private static class Entry {
        final String otp;
        final long createdAt;

        Entry(String otp, long createdAt) {
            this.otp = otp;
            this.createdAt = createdAt;
        }
    }
}
