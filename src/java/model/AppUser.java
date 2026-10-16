package model;

import java.util.Collections;
import java.util.HashSet;
import java.util.Locale;
import java.util.Set;

public class AppUser {
    private int userId;
    private String username;
    private String passwordHash;
    private String fullName;
    private String email;
    private int roleId;
    private boolean status;
    private String roleName;
    private Set<String> permissions = new HashSet<>();

    public AppUser() {
    }

    public AppUser(int userId, String username, String passwordHash, String fullName, String email, int roleId, boolean status, String roleName) {
        this.userId = userId;
        this.username = username;
        this.passwordHash = passwordHash;
        this.fullName = fullName;
        this.email = email;
        this.roleId = roleId;
        this.status = status;
        this.roleName = roleName;
    }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public int getRoleId() { return roleId; }
    public void setRoleId(int roleId) { this.roleId = roleId; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }

    public String getRoleName() { return roleName; }
    public void setRoleName(String roleName) { this.roleName = roleName; }

    public Set<String> getPermissions() {
        return permissions == null ? Collections.<String>emptySet() : Collections.unmodifiableSet(permissions);
    }

    public void setPermissions(Set<String> permissions) {
        this.permissions = new HashSet<>();
        if (permissions != null) {
            for (String perm : permissions) {
                if (perm != null && !perm.trim().isEmpty()) {
                    this.permissions.add(perm.trim().toUpperCase(Locale.ROOT));
                }
            }
        }
    }

    public boolean hasPermission(String permission) {
        if ("ADMIN".equalsIgnoreCase(roleName)) {
            return true;
        }
        if (permission == null || permissions == null) {
            return false;
        }
        return permissions.contains(permission.trim().toUpperCase(Locale.ROOT));
    }
}