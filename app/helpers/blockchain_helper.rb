module BlockchainHelper
  def qr_image_tag(uri)
    link_to(
      image_tag("https://chart.googleapis.com/chart?cht=qr&chs=200&chl=#{uri}"),
      uri
    )
  end

  def bitcoin_uri(address, amount, label = "Order #{current_order.number}")
    URI.encode([
      "bitcoin:#{address}",
      "?amount=#{amount}",
      ("&label=#{label}" if label)
    ].compact.join)
  end
end
