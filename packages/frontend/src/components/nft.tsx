
//component for the NFTs

export function nft() {
    return (
      <div className="card w-96 bg-base-100 shadow-xl">
        <figure><img src="https://placeimg.com/400/225/arch" alt="Shoes" /></figure>
        <div className="card-body">
          <h2 className="card-title">Id</h2>
          <p>Description</p>
          <div className="card-actions justify-end">
            <button className="btn btn-secondary">Buy Now</button>
          </div>
        </div>
      </div>
    )
  }