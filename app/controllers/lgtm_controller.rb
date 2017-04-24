require 'rmagick'

module Magick
  class Draw
    def font(name)
      primitive "font '#{name}'"
    end
    def font_family(name)
      primitive "font_family '#{name}'"
    end
  end
end

class LgtmController < ApplicationController
  def convert
    @file_name = params[:url]&.gsub('/','')
    @file_path = "public/images/#{ @file_name }"

    unless File.exist?(@file_path)
      begin
        # 画像の保存
        proc = Proc.new { |file| file << open(params[:url]).read }
        @file = open(@file_path, 'wb', &proc)
        # 画像の加工
        imgs = Magick::ImageList.new(@file.path)
        gif = create_gif(imgs)
        gif.write(@file.path)
      rescue => e
        pp e
      ensure
        imgs&.destroy!
        gif&.destroy!
      end
    end
    # 画像の表示
    send_data(File.read(@file_path), filename: @file_name)
    File.delete(@file.path)
  end

  def create_gif(imgs)
    result = Magick::ImageList.new
    draw = Magick::Draw.new

    img = imgs.first
    pointsize = img.columns / 6

    imgs.each.with_index do |img, index|
      begin
        draw.annotate(img, 0, 0, 0, 0, 'LGTM') do
          self.font        = Rails.root.join('app', 'assets', 'fonts', 'PalanquinDark-Bold.ttf').to_s
          self.font_family = "PalanquinDark-Bold"
          self.fill        = 'white'
          self.stroke      = 'transparent'
          self.pointsize   = pointsize
          self.gravity     = Magick::CenterGravity
        end
      rescue => e
        pp e
      end

      result.push(img)
      break if index > 100 # 100フレーム以下にする
    end
    result.optimize_layers(Magick::OptimizeTransLayer).deconstruct
  end
end
