c ce programme vise a decomposer un spectre en une somme de spectres de
c base en minimisant l equart quadratique moyen
c
c
c copyright....
c
c Declaration des variables
c
       integer i,j,npts,nbases, nlmaxi(32),jj,nn
       integer ninterv,ni,nit
       real*8 lambda(1254), spi(1254), spb(1254,32),maxi(32)
       real*8 lmax(100),lmin(100),zmax(100),zmin(100)
       real*8 lmaxi(32),spo(1254), coeff(32) ,signe(32)  
       real*8 toto, ancienrms,rms,facteur(32),rmsflag,brms
       character*64 nombase(32)
c
c initialisation des variables
c   coefficients initiaux
      ancien=0.
      ancienrms=100000000.
      do i=1,1254
        spo(i)=0.
      enddo
      do j=1,32   
        signe(j)=1.  
        maxi(j)=0. 
        lmaxi(j)=0.
        nlmaxi(j)=0
        coeff(j)=0.5
        facteur(j)=0.5 
      enddo      
       npts=10000
       nbases=0
       do i=1,1254
          lambda(i)=0.
          spi(i)=0.
          spo(i)=0.
         do j=1,32
             spb(i,j)=0.
          enddo
       enddo
c lecture du fichier d entree
       open(unit=4,file='synthetiseur.in',status='old')
          read(4,*) nbases
          print*,'nombre de bases',nbases
          do i=1,nbases
             read(4,*) nombase(i)
          enddo
       read(4,*) npts
       read(4,*) ninterv
       do i=1,ninterv
          read(4,*) lmin(i), lmax(i)
       enddo
       read(4,*) nzero
       do i=1,nzero
          read(4,*) zmin(i), zmax(i)
       enddo
       close(unit=4)
c lecture du spectre a reproduire
       open(unit=1,status='old',file='spi.txt') 
         do i=1,npts
            read(1,*,end=100) lambda(i), spi(i)
            do ii=1,nzero
               if ((lambda(i).ge.zmin(ii)).and.(lambda(i).le.
     +         zmax(ii))) then
               spi(i)=0.
               endif
            enddo
         enddo
  100  close(unit=1)
       do j=1,nbases
          open(unit=2,status='old',file=nombase(j))      
            do i=1,npts
               read(2,*,end=101) toto, spb(i,j)
            enddo
 101   enddo
c
c recherche de la longueur d onde du maximum de chaque base
c
       do j=1,nbases
         do i=1,npts
          if (spb(i,j).gt.maxi(j)) then
          maxi(j)=spb(i,j)
          lmaxi(j)=lambda(i)
          nlmaxi(j)=i
          endif
         enddo
       enddo
         do jj=1,nbases
          coeff(jj)=spi(nlmaxi(jj))/spb(nlmaxi(jj),jj)/2.
         enddo
c boucle de convergence 
c creation d un premier spectre synthetise avec les coefficients initiaux
       nit=0
       do n=1,100
         if (abs(brms-rms)/rms.lt.0.00001) goto 201
          brms=rms
         do jj=1,nbases  
           ancienrms=10000000000.
           do nn=1,5
             nit=nit+1
             do i=1,npts
               spo(i)=0.
             enddo
             do j=1,nbases
               do i=1,npts
                 spo(i)=spo(i)+coeff(j)*spb(i,j)
               enddo
             enddo
             rms=0.
             do i=1,npts
               rmsflag=1.
               do ni=1,ninterv
                 if ((lambda(i).ge.lmin(ni)).and.(lambda(i).lt.
     +           lmax(ni))) then
                   rmsflag=0.
                 endif
               enddo
               rms=rms+rmsflag*(spi(i)-spo(i))**2.
             enddo
             if (rms.gt.ancienrms) then
               signe(jj)=-signe(jj)
               facteur(jj)=facteur(jj)/1.1
             endif 
             ancienrms=rms
             coeff(jj)=coeff(jj)+signe(jj)*coeff(jj)*facteur(jj)
           enddo
         enddo
  200  enddo
  201  print*,'niteration=',nit,' rms=',rms,abs(brms-rms)
       do jj=1,nbases
         print*,nombase(jj),' coefficient=',coeff(jj)
       enddo
c ecriture du spectre reproduit
       open(unit=3,status='unknown',file='spo.txt') 
         do i=1,npts
           write(3,*) lambda(i), spo(i)
         enddo
       close(unit=3) 
       open(unit=7,status='unknown',file='res.txt') 
         do i=1,npts
           write(7,*) lambda(i), spo(i)-spi(i)
         enddo
       close(unit=7)
       open(unit=9,status='unknown',file='spi.txt') 
         do i=1,npts
           write(9,*) lambda(i), spi(i)
         enddo
       close(unit=9)
       open(unit=8,status='unknown',file='coefficient.txt') 
         write(8,*) 'Coefficient Base name'
         do i=1,nbases
           write(8,1000) coeff(i),nombase(i)
         enddo
       close(unit=8)
 1000  format(F10.2,3x,A)
       stop
       end

