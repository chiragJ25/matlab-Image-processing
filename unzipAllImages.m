# Unzip all the compressed image files that have 1 tif file and 1 tfw file and store the information in a csv file
#f is the path to the folder containing all zip files
# deleteOld = true
# outputcoverage is the name of the csv file along with its path
#temdir is where the zip file will be unzipped

function unzipAllImages( f, outputcoverage, tempdir, deleteOld )
# declare output variables
zip_files = dir(sprintf("%s/*.zip",f));
#zipfiles has all the zip files in the specified directory
for k=1: numel(zip_files)   
    tifName = "";
    tfwName = "";
    fp = sprintf("%s/%s",f,zip_files(k).name);
# delete temp stuff that was stored before
 #   if deleteOld 
   #   delete([tempdir '/*']);
    #endif
    
# unzip the files
    try
      fnames = unzip(fp, [tempdir '/tmp1']);
      
      if (numel(fnames) ~= 2) 
        error('Expect to have two files in archive. Assigning empty string to the output.');
        confirm_recursive_rmdir (0);
        rmdir ([tempdir '/tmp/'],"s");
        confirm_recursive_rmdir (1);
        return;
      end
# move file to folder and delete tmp folder
      movefile ([tempdir '/tmp1/' fnames{1}], [tempdir '/' fnames{1}]);
      movefile ([tempdir '/tmp1/' fnames{2}], [tempdir '/' fnames{2}]);
      confirm_recursive_rmdir (0);
      rmdir ([tempdir '/tmp1/'],"s");
      confirm_recursive_rmdir (1);
      
    catch ME
      error('could not find the zip file. Assigning empty string to the output.');
      return;
    end_try_catch
    
    
    tfwName = [tempdir '/' fnames{1}];
    tifName = [tempdir '/' fnames{2}];
    if index(fnames{1},".tif")>0
      tfwName = [tempdir '/' fnames{2}];
      tifName = [tempdir '/' fnames{1}];
    endif
    
    clear fnames;
    coordinates = struct();
    imagenpos = load(tfwName);
    coordinates.imageName = tfwName;
    coordinates.pixelX = imagenpos(1);
    coordinates.rotationX = imagenpos(2);
    coordinates.rotationY = imagenpos(3);
    coordinates.pixelY = imagenpos(4);
    coordinates.easting = imagenpos(5);
    coordinates.northing = imagenpos(6);
    est_end = coordinates.easting + ((size(imread(tifName))(2)) * coordinates.pixelX);
    nrt_end = coordinates.northing - ((size(imread(tifName))(1)) * coordinates.pixelX);
    pixelXvalue = coordinates.pixelX;
    rotationXvalue = coordinates.rotationX;
    rotationYvalue = coordinates.rotationY;
    pixelYvalue = coordinates.pixelY;
    est_start = coordinates.easting;
    # if this is the first file to read, use write mode to open file
    # otherwise, use append mode to open the file
    if(k ==1)
      fid = fopen(outputcoverage,'w');
      fprintf(fid, "%s,%s,%f,%f,%f,%f,%f,%f,%f,%f\n",tifName,tfwName,coordinates.pixelX,coordinates.rotationX, coordinates.rotationY,coordinates.pixelY,coordinates.easting,coordinates.northing,est_end,nrt_end);
      fclose(fid);
    else 
      fid = fopen(outputcoverage,'a');
      fprintf(fid, "%s,%s,%f,%f,%f,%f,%f,%f,%f,%f\n",tifName,tfwName,coordinates.pixelX,coordinates.rotationX, coordinates.rotationY,coordinates.pixelY,coordinates.easting,coordinates.northing,est_end,nrt_end);
      fclose(fid);
    end
 confirm_recursive_rmdir (0);
 rmdir ([tempdir],"s");
 confirm_recursive_rmdir (1);
 end   
 
endfunction 