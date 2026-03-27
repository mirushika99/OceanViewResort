package Test;

import com.oceanview.oceanviewresort.util.PasswordUtil;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class PasswordHash {

    @Test
    void testHashNotNull() {
        String hash = PasswordUtil.hashPassword("Test@123");
        assertNotNull(hash, "Hash should not be null");
    }

    @Test
    void testHashConsistency() {
        String h1 = PasswordUtil.hashPassword("Test@123");
        String h2 = PasswordUtil.hashPassword("Test@123");
        assertEquals(h1, h2, "Same input must produce same hash");
    }

    @Test
    void testDifferentPasswordsDifferentHashes() {
        String h1 = PasswordUtil.hashPassword("Password1");
        String h2 = PasswordUtil.hashPassword("Password2");
        assertNotEquals(h1, h2, "Different passwords must differ");
    }

    @Test
    void testIsValidPasswordTrue() {
        assertTrue(PasswordUtil.isValidPassword("Test@123"));
    }

    @Test
    void testIsValidPasswordFalse() {
        assertFalse(PasswordUtil.isValidPassword("abc"));
    }
}

