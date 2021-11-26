const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory("MetaKombat");

  const gameContract = await gameContractFactory.deploy(
    ["Scorpion", "Cassie cage", "Ermac", "Cyrax", "Erron Black", "Kitana"], // Names
    [
      "QmaYXmYyfGkCfanbaGQNCR3Z8NBdBC1DMP5jrPQPZ9dM8U", // Images
      "QmbA4ULsBDJikbCnbsKcU2p6hwUR2RduYE8z5ShuTWLYY3",
      "QmfZopJUmeN8LmgGsPu6YcJFcW5XVub6jKC45kJGvNHYa5",
      "QmP5kq7LJmkeHGJFA5T4uQACNXRn9kPF5LLCVCXhith5Jm",
      "QmVGifaBuihnnD5gCn4aGGt6EiFLdrj4Zu5PuLkBK9DQPS",
      "QmdSKL8hG7ykGd6oZcuMhsRzy8CjsCHqv4RSyuBN3dE4CZ",
    ],
    [100, 120, 85, 150, 175, 75], // HP values
    [25, 20, 33, 18, 15, 40], // Attack damage values
    "Shao Khan",
    "QmRWAyjSfLYYZkBAZfDff6NJJy5Upv9EbFB61pyq4rqZ9o",
    250,
    32
  );

  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

  let txn;
  // We only have three characters.
  // an NFT w/ the character at index 2 of our array.

  txn = await gameContract.mintCharacterNFT(2);
  await txn.wait();

  txn = await gameContract.mintCharacterNFT(0);
  await txn.wait();

  txn = await gameContract.mintCharacterNFT(4);
  await txn.wait();

  // txn = await gameContract.checkIfUserHasNFT();
  // await txn.wait();

  // txn = await gameContract.attackBoss();
  // await txn.wait();

  console.log("Done!");
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
