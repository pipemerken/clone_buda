require "uri"
require "net/http"
require "json"

def consult (urlText)
  url = URI(urlText)
  https = Net::HTTP.new(url.host, url.port);
  https.use_ssl = true
  request = Net::HTTP::Get.new(url)
  request["Cookie"] = "__cfduid=d6edcf5d51aef6cdfdd764b10c75473591595898693; __cflb=0H28uvGmWCzZDa7fgtY59KA2G7K1qEw7K8gBqoku7p1"
  response = https.request(request)
  body = JSON.parse response.read_body
end

namesMarket = [] 
consult("https://www.buda.com/api/v2/markets").each do |clave|
   clave[1].each do |k|
    namesMarket.push([k["id"], k["base_currency"]])
    end
end

def extractTransaction(response)
transactions = []
  response.each do |k,v|
    v["entries"].each do |x|
        transactions.push([x[1].to_f.round(4), x[2].to_f.round(4)])
    end
  end
  return transactions
end

def extractName(response)
  names = []
  response.each do |k,v|
    names.push(v["market_id"])
  end
  return names
end

def consultOneDay(urlText)
  uri = URI(urlText)
  params = { :limit => 100, :timestamp => (Time.now.to_i  * 1000) - (60*60*24) }
  uri.query = URI.encode_www_form(params)
  res = Net::HTTP.get_response(uri)
  JSON.parse res.body if res.is_a?(Net::HTTPSuccess)
end

namesMarket.each do |i|
  response = consultOneDay("https://www.buda.com/api/v2/markets/#{i[0]}/trades")
  transactions = extractTransaction(response)
  names = extractName(response)
  transactionsMax = transactions.max
  puts "- Para el mercado #{names[0]}" , "- La transaccion con mayor valor en las ultimas 24 horas fue:"," - Cantidad: #{transactionsMax[0]} - Precio: #{transactionsMax[1]} #{i[1]} "
end

