# Handles extracting features from images that are uploaded.
class Feature_extractor < Paperclip::Processor

  # Creates a Feature_extractor object set to work on the +file+ given. It
  # will attempt to extract features from the supplied image

  def initialize(file, options = {}, attachment = nil)
    logger.debug "Into Feature_extractor#initialize"
    super
    @file                = file
    @current_format      = File.extname(@file.path)
    @basename            = File.basename(@file.path, @current_format)
  end

  # Performs the extraction of features from the +file+ into an extraction file. Returns the Tempfile
  # that contains the features.
  def make
    logger.debug "Into Feature_extractor#make"
    src = @file
#      dst = Tempfile.new([@basename, @format ? ".#{@format}" : ''])
    dst = Tempfile.new([@basename, ".feq"])
    dst.binmode

    begin
      parameters = []
      parameters << ":source"
      parameters << ":dest"

      parameters = parameters.flatten.compact.join(" ").strip.squeeze(" ")

      success = extract(parameters, :source => File.expand_path(src.path), :dest => File.expand_path(dst.path))
    rescue Cocaine::ExitStatusError => e
      raise Paperclip::Error, "There was an error processing the extraction for @basename"
    rescue Cocaine::CommandNotFoundError => e
      raise Paperclip::Errors::CommandNotFoundError.new("Could not run the `feature_extract` command. Please install ImageMagick.")
    end

    dst
  end

  # The extract method runs the feature_extract binary with the provided arguments.
  # See Paperclip.run for the available options.
  def extract(arguments = "", local_options = {})
    Paperclip.run('feature_extract', arguments, local_options)
  end

end
