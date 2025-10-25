-- AlterTable
ALTER TABLE "products" ADD COLUMN "productLine" TEXT;
ALTER TABLE "products" ADD COLUMN "processor" TEXT;
ALTER TABLE "products" ADD COLUMN "ram" TEXT;
ALTER TABLE "products" ADD COLUMN "storage" TEXT;
ALTER TABLE "products" ADD COLUMN "screenSize" TEXT;

-- CreateIndex
CREATE INDEX "products_productLine_idx" ON "products"("productLine");
CREATE INDEX "products_processor_idx" ON "products"("processor");
CREATE INDEX "products_ram_idx" ON "products"("ram");
CREATE INDEX "products_storage_idx" ON "products"("storage");
CREATE INDEX "products_company_category_idx" ON "products"("company", "category");
CREATE INDEX "products_price_productLine_idx" ON "products"("price", "productLine");

