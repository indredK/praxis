/*
  Warnings:

  - You are about to drop the column `stock` on the `products` table. All the data in the column will be lost.
  - Added the required column `category` to the `products` table without a default value. This is not possible if the table is not empty.
  - Added the required column `company` to the `products` table without a default value. This is not possible if the table is not empty.
  - Added the required column `imageUrl` to the `products` table without a default value. This is not possible if the table is not empty.
  - Added the required column `releaseDate` to the `products` table without a default value. This is not possible if the table is not empty.
  - Added the required column `specifications` to the `products` table without a default value. This is not possible if the table is not empty.
  - Added the required column `specs` to the `products` table without a default value. This is not possible if the table is not empty.
  - Made the column `description` on table `products` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
ALTER TABLE "products" DROP COLUMN "stock",
ADD COLUMN     "category" TEXT NOT NULL,
ADD COLUMN     "company" TEXT NOT NULL,
ADD COLUMN     "imageUrl" TEXT NOT NULL,
ADD COLUMN     "releaseDate" TIMESTAMP(3) NOT NULL,
ADD COLUMN     "specifications" JSONB NOT NULL,
ADD COLUMN     "specs" JSONB NOT NULL,
ALTER COLUMN "description" SET NOT NULL,
ALTER COLUMN "description" SET DEFAULT '';

-- CreateTable
CREATE TABLE "filter_configs" (
    "id" TEXT NOT NULL,
    "filterTree" JSONB NOT NULL,
    "comparisonModes" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "filter_configs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "products_company_idx" ON "products"("company");

-- CreateIndex
CREATE INDEX "products_category_idx" ON "products"("category");

-- CreateIndex
CREATE INDEX "products_price_idx" ON "products"("price");
