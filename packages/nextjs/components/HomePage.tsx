"use client";

import React, { useEffect, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useDispatch, useSelector } from "react-redux";
import { useScaffoldReadContract } from "~~/hooks/scaffold-eth";
import { RootState } from "~~/store/store";

const idProject: string = process.env.ID_PROJECT || "";

const HomePage: React.FC = () => {
  const orderFromState = useSelector((state: RootState) => state.order.order);
  const [isOrderAccepted, setIsOrderAccepted] = useState(false);

  const handleOrderClick = (connectWallet: () => void, isConnected: boolean) => {
    if (!isConnected) {
      connectWallet();
    }
  };

  const { data: orderStatus } = useScaffoldReadContract({
    contractName: "DispatchEcho",
    functionName: "dispatchStatus", // Supongo que esta función devuelve el estado de la orden.
    args: [BigInt(idProject)],
  });

  useEffect(() => {
    if (orderStatus && orderStatus === 1) {
      // Aquí asumo que 1 representa el estado "Accepted"
      setIsOrderAccepted(true);
    }
  }, [orderStatus]);

  return (
    <div className="bg-[#FFFAF2] p-[20px] h-full min-h-screen justify-evenly flex flex-col">
      <div>
        <Image alt="home" width={350} height={36} src="/dispatch.png" />
      </div>
      <div className="flex w-full justify-center">
        <Image alt="home" className="w-[350px] h-[266px]" width={350} height={266} src="/Image.png" />
      </div>
      <div className="flex flex-col gap-[12px]">
        <p className="p-0 m-0 text-[20px] font-bold">
          Connect directly with couriers and businesses for fast, reliable deliveries.
        </p>
        <p className="p-0 m-0 text-[20px] text-[#53524F]">Log in securely with your wallet. </p>
      </div>
      <div className="flex w-full items-center justify-center flex-col gap-[24px]">
        <ConnectButton.Custom>
          {({ account, openConnectModal, mounted }) => {
            const isConnected = Boolean(mounted && account);

            if (!isConnected) {
              return (
                <div className="max-w-[350px] w-full bg-[#D76C45] h-[57px] rounded-[12px]">
                  <button className="w-full h-full text-[#FFFFFF]" onClick={openConnectModal}>
                    Connect your wallet
                  </button>
                </div>
              );
            }

            return (
              <>
                <div className="max-w-[350px] w-full bg-[#D76C45] h-[57px] rounded-[12px]">
                  <Link href={isOrderAccepted ? "/finish-order" : "/checkout"}>
                    <button
                      className="w-full h-full text-[#FFFFFF]"
                      onClick={() => {
                        handleOrderClick;
                      }}
                    >
                      Make an order
                    </button>
                  </Link>
                </div>
                <div className="max-w-[350px] w-full rounded-[12px] border border-solid border-[#D76C45] h-[57px]">
                  <Link href={"/delivering"}>
                    {" "}
                    <button className="w-full h-full text-[#D76C45]">Start delivering</button>
                  </Link>
                </div>
              </>
            );
          }}
        </ConnectButton.Custom>
      </div>
    </div>
  );
};

export default HomePage;
