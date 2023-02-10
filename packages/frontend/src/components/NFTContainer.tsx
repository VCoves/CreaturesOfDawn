
// container for personal NFTs

import type { NFT } from "../types/nft";

export const NFTContainer = (props: { nfts: NFT[] }) =>{
    const { nfts } = props;
    return (
      <div>
        {nfts.map((nft) => (
          <div key={nft.id}>
            <h3>{nft.name}</h3>
            <img src={nft.image} alt={nft.name} />
          </div>
        ))}
      </div>
    );
  };
  
