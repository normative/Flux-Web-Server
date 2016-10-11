#module Paperclip
# Handles extracting features from images that are uploaded.
class FeatureExtractor < Paperclip::Processor

  # Creates a Feature_extractor object set to work on the +file+ given. It
  # will attempt to extract features from the supplied image

  def initialize(file, options = {}, attachment = nil)
#    logger.debug "Into FeatureExtractor#initialize"
    super
    @file                = file
    @current_format      = File.extname(@file.path)
    @basename            = File.basename(@file.path, @current_format)
    @cvt_to_xml          = options[:cvt_to_xml].nil? ? false : options[:cvt_to_xml]
 end

  # Performs the extraction of features from the +file+ into an extraction file. Returns the Tempfile
  # that contains the features.
  def make
#    logger.debug "Into FeatureExtractor#make"
    src = @file
    dst = Tempfile.new([@basename, @format ? ".#{@format}" : ""])

#    if @cvt_to_xml
#      dst = Tempfile.new([@basename, ".xml"])
#    else
#      dst = Tempfile.new([@basename, ".bin"])
#    end

    dst.binmode


    begin
      parameters = []
      parameters << ":source"
      parameters << ":dest"
      if @cvt_to_xml
        parameters << "--cvt_to_xml"
      else
        parameters << "--auto_threshold"
        parameters << "--min_thresh 100"
        parameters << "--max_thresh 10000"
      end

      parameters = parameters.flatten.compact.join(" ").strip.squeeze(" ")

      success = extract(parameters, :source => "#{File.expand_path(src.path)}", :dest => File.expand_path(dst.path))
    rescue Cocaine::ExitStatusError => e
      raise Paperclip::Error, "There was an error processing the extraction for @basename"
    rescue Cocaine::CommandNotFoundError => e
      Rails.logger.info(e)
      raise Paperclip::Errors::CommandNotFoundError.new("Could not run the `feature_extract` command. Please install.")
    end

    dst
  end

  # The extract method runs the feature_extract binary with the provided arguments.
  # See Paperclip.run for the available options.
  def extract(arguments = "", local_options = {})
    Paperclip.run('descriptor_extract', arguments, local_options)
  end

end
#end
