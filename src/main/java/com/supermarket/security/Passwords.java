package com.supermarket.security;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.security.*;
import java.util.*;
public final class Passwords {
  private Passwords() {}
  public static String hash(String pass){
    byte[] salt=new byte[16];new SecureRandom().nextBytes(salt);
    return derive(pass,salt);
  }
  private static String derive(String pass,byte[] salt){
    try {
      PBEKeySpec spec=new PBEKeySpec(pass.toCharArray(),salt,210000,256);
      byte[] key=SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
      spec.clearPassword();
      return "pbkdf2_sha256$210000$"+Base64.getEncoder().encodeToString(salt)+"$"+Base64.getEncoder().encodeToString(key);
    } catch(Exception e){throw new IllegalStateException("Password hashing failed",e);}
  }
  public static boolean verify(String pass,String encoded){
    try {
      String[] a=encoded.split("\\$"); if(a.length!=4||!a[0].equals("pbkdf2_sha256")||!a[1].equals("210000"))return false;
      byte[] salt=Base64.getDecoder().decode(a[2]);
      return MessageDigest.isEqual(Base64.getDecoder().decode(a[3]),Base64.getDecoder().decode(derive(pass,salt).split("\\$")[3]));
    }catch(Exception e){return false;}
  }
}
