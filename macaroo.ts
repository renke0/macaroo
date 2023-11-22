import prompts from "prompts";
import * as crypto from "crypto";
import {promises as fs} from "fs";

const GITHUB_USERNAME = /^[a-z\d](?:[a-z\d]|-(?=[a-z\d])){0,38}$/i;
const COMMON_NAME = /^[a-z\d](?:[a-z\d]|-(?=[a-z\d])){0,62}$/i;
const EMAIL = /^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$/;

async function route(args: string[]) {
  switch (args[0]) {
    case "config":
      return await readUserConfiguration(args[1], args[2]);
    case "decrypt":
      return await decrypt(args[1], args[2]);
    case "hostfile":
      return await createHostFile(args[1], args[2]);
  }
}

async function readUserConfiguration(password: string, fileName: string): Promise<void> {
  const config = {
    computerName: await readComputerName(),
    github: await readGithubConfiguration(),
  };
  const encrypted = await encrypt(JSON.stringify(config), password);
  const fileContents = JSON.stringify(encrypted);
  await fs.writeFile(fileName, fileContents, "utf-8");
}

async function readComputerName(): Promise<string> {
  const result = await prompts({
    message: "Enter the name you want to give to this computer",
    type: "text",
    name: "computerName",
    validate: (input) => (COMMON_NAME.test(input) ? true : "Invalid computer name"),
  });
  return result.computerName;
}

async function readGithubConfiguration(): Promise<GithubConfiguration> {
  const users = await readGithubUsers();
  const profiles = await readGithubProfiles(users);
  for (const profile of profiles) {
    profile.user = users.find((user) => user.username === profile.user)!;
  }
  return {
    users: users,
    profiles: profiles,
  };
}

async function readGithubUsers(): Promise<GithubUser[]> {
  let addMore = true;
  const users: GithubUser[] = [];
  while (addMore) {
    const result = await prompts([
      {
        message: "Enter the github username",
        type: "text",
        name: "username",
        validate: (input) => {
          if (!GITHUB_USERNAME.test(input)) return "Invalid username";
          if (users.some((user) => input === user.username)) return "Duplicated user";
          return true;
        },
      },
      {
        message: "Enter the github email",
        type: "text",
        name: "email",
        validate: (input) => (EMAIL.test(input) ? true : "Invalid email"),
      },
      {
        message: "Enter the github subdomain",
        type: "text",
        name: "domain",
      },
      {
        message: "Enter the gpg passphrase",
        type: "password",
        name: "gpgPassphrase",
      },
      {
        message: "Enter the ssh passphrase",
        type: "password",
        name: "sshPassphrase",
      },
      {
        message: "Do you want to add more users?",
        type: "confirm",
        name: "addMore",
        initial: true,
      },
    ]);
    addMore = result.addMore;
    delete result.addMore;
    users.push({...result});
  }
  return users;
}

async function readGithubProfiles(users: GithubUser[]): Promise<GithubProfile[]> {
  let addMore = true;
  const profiles: GithubProfile[] = [];
  while (addMore) {
    const result = await prompts([
      {
        message: "Enter the profile name",
        type: "text",
        name: "name",
        validate: (input) => (COMMON_NAME.test(input) ? true : "Invalid profile name"),
      },
      {
        message: "What user do you want to associate with this profile?",
        type: "select",
        name: "user",
        choices: users.map((user) => ({
          title: `${user.username} <${user.email}> (${user.domain}${user.domain ? "." : ""}github.com)`,
          value: user.username,
        })),
      },
      {
        message: "Do you want to add more profiles?",
        type: "confirm",
        name: "addMore",
        initial: true,
      },
    ]);
    addMore = result.addMore;
    delete result.addMore;
    profiles.push({...result});
  }
  return profiles;
}

function deriveKeyFromPassword(password: string, salt: Buffer, iterations: number, keyLength: number): Buffer {
  return crypto.pbkdf2Sync(password, salt, iterations, keyLength, "sha256");
}

async function encrypt(text: string, password: string): Promise<EncryptedText> {
  const salt = crypto.randomBytes(16);
  const key = deriveKeyFromPassword(password, salt, 100000, 32);
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv("aes-256-cbc", key, iv);
  let encrypted = cipher.update(text, "utf-8", "hex");
  encrypted += cipher.final("hex");
  return {
    salt: salt.toString("hex"),
    iv: iv.toString("hex"),
    encryptedText: encrypted,
  };
}

async function decrypt(password: string, fileName: string): Promise<void> {
  const rawData = await fs.readFile(fileName, "utf-8");
  const data = JSON.parse(rawData);
  const key = deriveKeyFromPassword(password, Buffer.from(data.salt, "hex"), 100000, 32);
  const decipher = crypto.createDecipheriv("aes-256-cbc", key, Buffer.from(data.iv, "hex"));
  let decrypted = decipher.update(data.encryptedText, "hex", "utf-8");
  decrypted += decipher.final("utf-8");
  console.log(decrypted);
}

async function createHostFile(githubString: string, fileName: string) {
  const github: GithubConfiguration = JSON.parse(githubString);
  const sshEntries = resolveEntries(github);

  let fileContents = "# Autogenerated by .macaroo";
  for (const entry of sshEntries) {
    fileContents += `
Host ${entry.host}
  HostName ${entry.hostname}
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_${entry.username}`;
  }
  await fs.writeFile(fileName, fileContents, "utf-8");
}

function resolveEntries(github: GithubConfiguration) {
  const baseGithubDomain = "github.com";
  const entries: SSHEntry[] = [];
  for (const profile of github.profiles) {
    const user = profile.user as GithubUser;
    const entry = {host: baseGithubDomain, hostname: baseGithubDomain, username: user.username};
    if (user.domain.length != 0) {
      entry.host = `${user.domain}.${baseGithubDomain}`;
      entry.hostname = `${user.domain}.${baseGithubDomain}`;
    }
    if (entries.some((e) => e.host === entry.host && e.username !== entry.username)) {
      entry.host = `${profile.name}.${entry.host}`;
    }
    const compare = (left: SSHEntry, right: SSHEntry) =>
      left.host === right.host && left.hostname === right.hostname && left.username === right.username;
    if (!entries.some((e) => compare(e, entry))) {
      entries.push(entry);
    }
  }
  return entries;
}

type GithubConfiguration = {
  users: GithubUser[];
  profiles: GithubProfile[];
};

type GithubUser = {
  username: string;
  email: string;
  domain: string;
  gpgPassphrase: string;
  sshPassphrase: string;
};

type GithubProfile = {
  user: string | GithubUser;
  name: string;
};

type EncryptedText = {
  salt: string;
  iv: string;
  encryptedText: string;
};

type SSHEntry = {
  host: string;
  hostname: string;
  username: string;
};

(async () => route(process.argv.slice(2)))();
