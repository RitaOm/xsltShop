<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:def="http://www.example.org/products"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:good="xalan://com.epam.testapp.bean.Good"
	xmlns:validator="xalan://com.epam.testapp.validator.GoodValidator"
	xmlns:errors="xalan://com.epam.testapp.validator.GoodValidationErrors">

	<xsl:param name="category"></xsl:param>
	<xsl:param name="subcategory"></xsl:param>
	<xsl:param name="good"></xsl:param>
	<xsl:param name="validator"></xsl:param>
	<xsl:param name="validate"></xsl:param>
	<xsl:param name="errors"></xsl:param>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="$validate and validator:validate($validator, $good)">
				<xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="addForm" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*" />
		</xsl:copy>
	</xsl:template>

	<xsl:template
		match="products/category[@category_name=$category]/subcategory[@subcategory_name=$subcategory]">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*" />
			<xsl:element name="good">
				<xsl:element name="producer">
					<xsl:value-of select="good:getProducer($good)" />
				</xsl:element>
				<xsl:element name="model">
					<xsl:value-of select="good:getModel($good)" />
				</xsl:element>
				<xsl:element name="date">
					<xsl:value-of select="good:getDate($good)" />
				</xsl:element>
				<xsl:element name="color">
					<xsl:value-of select="good:getColor($good)" />
				</xsl:element>
				<xsl:choose>
					<xsl:when test="good:isNotInStock($good)">
						<xsl:element name="not_in_stock"></xsl:element>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="price">
							<xsl:value-of select="good:getPrice($good)" />
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:copy>
	</xsl:template>

	<xsl:template name="addForm">
		<html>
			<head>
				<title>Add new good</title>
				<link rel="stylesheet" href="/task3/resources/css/styles-xsl.css"></link>
			</head>
			<body>
				<div class="container">
					<xsl:choose>
						<xsl:when
							test="count(//category[@category_name=$category]/subcategory[@subcategory_name=$subcategory]) &gt; 0">
							<h1>
								Category:
								<xsl:value-of select="$category" />
							</h1>
							<h2>
								Subcategory:
								<xsl:value-of select="$subcategory" />
							</h2>
							<h3>Fill in the fields</h3>
							<form action="/task3/saveGood" method="post">
								<xsl:element name="input">
									<xsl:attribute name="type">hidden</xsl:attribute>
									<xsl:attribute name="name">category</xsl:attribute>
									<xsl:attribute name="value"><xsl:value-of
										select="$category" /></xsl:attribute>
								</xsl:element>
								<xsl:element name="input">
									<xsl:attribute name="type">hidden</xsl:attribute>
									<xsl:attribute name="name">subcategory</xsl:attribute>
									<xsl:attribute name="value"><xsl:value-of
										select="$subcategory" /></xsl:attribute>
								</xsl:element>
								<table class="content">
									<tr>
										<td>Producer:</td>
										<td>
											<xsl:element name="input">
												<xsl:attribute name="type">text</xsl:attribute>
												<xsl:attribute name="name">producer</xsl:attribute>
												<xsl:attribute name="value"><xsl:value-of
													select="good:getProducer($good)" /></xsl:attribute>
											</xsl:element>
											<span class="error">
												<xsl:value-of select="errors:getProducerError($errors)" />
											</span>
										</td>
									</tr>
									<tr>
										<td>Model:</td>
										<td>
											<xsl:element name="input">
												<xsl:attribute name="type">text</xsl:attribute>
												<xsl:attribute name="name">model</xsl:attribute>
												<xsl:attribute name="title">Consists of two letters and three digits</xsl:attribute>
												<xsl:attribute name="value"><xsl:value-of
													select="good:getModel($good)" /></xsl:attribute>
											</xsl:element>
											<span class="error">
												<xsl:value-of select="errors:getModelError($errors)" />
											</span>
										</td>
									</tr>
									<tr>
										<td>Date:</td>
										<td>
											<xsl:element name="input">
												<xsl:attribute name="type">text</xsl:attribute>
												<xsl:attribute name="name">date</xsl:attribute>
												<xsl:attribute name="placeholder">dd-MM-YYYY</xsl:attribute>
												<xsl:attribute name="value"><xsl:value-of
													select="good:getDate($good)" /></xsl:attribute>
											</xsl:element>
											<span class="error">
												<xsl:value-of select="errors:getDateError($errors)" />
											</span>
										</td>
									</tr>
									<tr>
										<td>Color:</td>
										<td>
											<xsl:element name="input">
												<xsl:attribute name="type">text</xsl:attribute>
												<xsl:attribute name="name">color</xsl:attribute>
												<xsl:attribute name="value"><xsl:value-of
													select="good:getColor($good)" /></xsl:attribute>
											</xsl:element>
											<span class="error">
												<xsl:value-of select="errors:getColorError($errors)" />
											</span>
										</td>
									</tr>
									<tr>
										<td>Price:</td>
										<td>
											<xsl:element name="input">
												<xsl:attribute name="type">text</xsl:attribute>
												<xsl:attribute name="name">price</xsl:attribute>
												<xsl:attribute name="title">Good has the price > 0 or isn't in stock</xsl:attribute>
												<xsl:attribute name="value"><xsl:value-of
													select="good:getPrice($good)" /></xsl:attribute>
											</xsl:element>
											<span class="error">
												<xsl:value-of select="errors:getPriceError($errors)" />
											</span>
										</td>
									</tr>
									<tr>
										<td>
											<xsl:element name="input">
												<xsl:attribute name="type">checkbox</xsl:attribute>
												<xsl:attribute name="name">not_in_stock</xsl:attribute>
												<xsl:if test="good:isNotInStock($good)">
													<xsl:attribute name="checked">checked</xsl:attribute>
												</xsl:if>
												Not in stock
											</xsl:element>
										</td>
										<td>
											<span class="error">
												<xsl:value-of select="errors:getNotInStockError($errors)" />
											</span>
										</td>
									</tr>
									<tr>
										<td></td>
										<td class="addpage-submit-save">
											<input type="submit" value="SAVE" />
										</td>
									</tr>
								</table>
							</form>
							<div class="content addpage-submit-back">
								<xsl:element name="button">
									<xsl:attribute name="onClick"><xsl:text>location.href='/task3/categories/</xsl:text><xsl:value-of
										select="$category" /><xsl:text>/</xsl:text><xsl:value-of
										select="$subcategory" /><xsl:text>'</xsl:text></xsl:attribute>
									<xsl:text>BACK</xsl:text>
								</xsl:element>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<h2>Can't add new product (wrong category or subcategory name)</h2>
							<a href="/task3/categories">Go to category list</a>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>