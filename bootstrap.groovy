import javax.crypto.Cipher
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec
import java.nio.charset.StandardCharsets

import static groovy.json.JsonOutput.*
import static org.fusesource.jansi.Ansi.*
import static org.fusesource.jansi.Ansi.Color.*

static main(args) {
  if (args) {
    "${args.head()}"(*args.tail())
  }
}

static userConfigs(String storePassword, String location) {
  def data = [
      computerName: prompt("What is the name you want to give to this computer?", simpleName()),
      gitProfiles : gitProfiles()]
  def encrypted = encrypt(prettyPrint(toJson(data)), storePassword)
  writeFile(encrypted, location)
}

static gitProfiles() {
  def addMore = prompt("Do you want to configure git profiles? (y/n)", yesNo())
  def profiles = []
  while (addMore.toLowerCase().startsWith("y")) {
    profiles << [
        name         : prompt("Enter the git profile name:", unique(profiles, { it["name"] }), simpleName()),
        username     : prompt("Enter the username for this profile:", simpleName()),
        email        : prompt("Enter the email for this profile:", unique(profiles, { it["email"] }), email()),
        sshPassphrase: promptSecret("Enter the passphrase for the SSH key:", notEmpty()),
        gpgPassphrase: promptSecret("Enter the passphrase for the GPG key:", notEmpty())]
    addMore = prompt("Do you want to add more profiles? (y/n)", yesNo())
  }
  return profiles
}

static yesNo() {
  return { it ==~ /(?i)^(y(es)?)|(no?)$/ ? null : "The value must be yes or no" }
}

static simpleName() {
  return {
    it ==~ /^[a-zA-Z0-9\-_]{1,63}$/ ? null : "The value must have only letters, numbers, '-' or '_', with a maximum of 63 characters"
  }
}

static unique(List values, def itemProvider) {
  return { val -> values.every { itemProvider(it) != val } ? null : "This value is duplicated" }
}

static notEmpty() {
  return { it != null && !it.isEmpty() ? null : "This value is required" }
}

static email() {
  return { it ==~ /^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$/ ? null : "The value must be a valid email address" }
}

static prompt(String message, Closure<String>... validators) {
  readInput({ System.console().readLine() }, message, validators)
}

static promptSecret(String message, Closure<String>... validators) {
  readInput({ new String(System.console().readPassword()) }, message, validators)
}

static readInput(Closure<String> reader, String message, Closure<String>... validators) {
  while (true) {
    printPrompt "> $message "
    def value = reader()
    def error = validators.findResult({ it(value) })
    if (error != null) printError error else return value
  }
}

static printMessage(String message) {
  println colorize(message, CYAN)
}

static printPrompt(String message) {
  print colorize(message, GREEN)
}

static printError(String message) {
  println colorize(message, RED)
}

static colorize(String message, Color color) {
  ansi().fg(color).a(message).reset()
}

static encrypt(String text, String secretKey) {
  return aes(
      secretKey,
      Cipher.ENCRYPT_MODE,
      { Cipher cipher ->
        def encryptedBytes = cipher.doFinal(text.bytes)
        return Base64.getEncoder().encodeToString(encryptedBytes)
      })
}

static decrypt(String text, String secretKey) {
  return aes(
      secretKey,
      Cipher.DECRYPT_MODE,
      { Cipher cipher ->
        def decryptedBytes = cipher.doFinal(Base64.getDecoder().decode(text))
        return new String(decryptedBytes, StandardCharsets.UTF_8)
      })
}


static aes(String secretKey, int mode, Closure<String> postProcessor) {
  def cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
  def keyBytes = secretKey.getBytes(StandardCharsets.UTF_8)
  def secretKeySpec = new SecretKeySpec(keyBytes, "AES")
  def ivParameterSpec = new IvParameterSpec(keyBytes, 0, cipher.getBlockSize())
  cipher.init(mode, secretKeySpec, ivParameterSpec)
  return postProcessor(cipher)
}

static writeFile(String content, String path) {
  def outputFile = new File(path)
  outputFile.createNewFile()
  outputFile.write(content)
}
