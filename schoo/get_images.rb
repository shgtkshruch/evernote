require 'net/http'

module Get_images
  # モジュールの変数を定義
  def init
    @forbin = false
    @slide_num = 1
  end

  def get_images(class_num)
    # モジュールの変数を有効
    init

    # レスポンスでエラーが返るまでループ
    while !@forbin
      path = "/i.schoo/images/class/slide/#{class_num}/#{@slide_num}-1024.jpg"
      get_http(path)
      @slide_num = @slide_num + 1
    end
  end

  def get_http(path)
    host = "s3-ap-northeast-1.amazonaws.com"

    Net::HTTP.start(host, 80) do |http|
      response = http.get(path)

      # レスポンスがあったらダウンロード
      if response.message == 'OK'

        # ファイル名の順番を整えるためにリネーム
        filename = get_index(@slide_num) + '.jpg'

        # イメージファイルを保存
        open(filename, 'wb') do |f|
          f.puts  response.body
        end

      # レスポンスがエラーだったらダウンロード終了
      else
        @forbin = true
      end
    end
  end

  # get_index(1) => 001
  # get_index(10) => 010
  # get_index(100) => 100
  def get_index(i)
    case i
    when 0...10
      index = "00#{i}"
    when 10...100
      index = "0#{i}"
    else
      index = i
    end
    index
  end
end
