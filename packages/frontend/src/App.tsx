import {nft} from './components/nft';
import {carousel} from './components/carousel';
import {navbar} from './components/navbar';
import {NFTContainer} from './components/NFTContainer';
import type {NFT} from './types/nft';



const nft1: NFT = {
  id: "1",
  name: 'NFT 1',
  description: 'NFT 1 description',
  image: 'https://picsum.photos/200/300',
  price: 1,
}
const nft2: NFT = {
  id: "2",
  name: 'NFT 2',
  description: 'NFT 2 description',
  image: 'https://picsum.photos/200/300',
  price: 1,
}

const nfts: NFT[] = [nft1, nft2];


export default function App() {
  return (
    <div>
      {navbar()}
      <div className="navbar" style={{ color: 'white', width: '98.85vw', alignItems: 'center', justifyContent: 'center', background: 'grey' }}>
        <h1>TOP COLLECTIONS</h1>
      </div>
      {carousel(nft())}
      <div className="navbar" style={{ color: 'white', width: '98.85vw', alignItems: 'center', justifyContent: 'center', background: 'grey' }}>
        <h1>YOUR NFTS</h1>
      </div>
      <div className="nft-container" >
      {NFTContainer({nfts})}
    </div>
    </div>
  );
}



